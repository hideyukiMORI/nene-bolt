#!/bin/bash
# 配布物を作る唯一の経路（QLT-014・ADR 0011）。移植元: NeNe Swarm eng/package-release.sh（コミット a660f47。元は NeNe Gambit の 64b82ec）。
#
#   eng/package-release.sh [v<版>]
#
# 単一ゲートとは別のビルドディレクトリ（.release/build）で、規約検査・release 構成のテスト・標準ライブラリを静的にリンクしたビルドを通し、
# 成果物を検査してから .release/out に tar.gz と SHA256SUMS を作る。検査に落ちたら何も作らない。
# この検査は PR の最終 HEAD で回すフルゲート（make check）の代わりではない。
set -euo pipefail
cd "$(dirname "$0")/.."

fail() {
    echo "package-release: $1" >&2
    exit 1
}

version="$(sed -n 's/^    static let current = "\([0-9][0-9.]*\)"$/\1/p' Sources/nene-bolt/Version.swift)"
[ -n "$version" ] || fail "Sources/nene-bolt/Version.swift から版を読めない"
if [ $# -ge 1 ] && [ "$1" != "v$version" ]; then
    fail "タグ $1 が版 v$version と違う"
fi

name="nene-bolt-${version}-linux-x86_64"
build=.release/build
stage=".release/stage/$name"
out=.release/out
rm -rf .release/stage "$out"
mkdir -p "$stage" "$out"

python3 eng/conformance.py
eng/swift-strict.sh swift test -c release --scratch-path "$build"
eng/swift-strict.sh swift build -c release --static-swift-stdlib --product nene-bolt --scratch-path "$build"

binary="$build/release/nene-bolt"
install -m 0755 "$binary" "$stage/nene-bolt"
strip "$stage/nene-bolt"
sed "s/@VERSION@/$version/g" eng/release/README.txt > "$stage/README.txt"
cp LICENSE "$stage/LICENSE"

# 成果物の検査
file "$stage/nene-bolt" | grep -q 'ELF 64-bit LSB pie executable, x86-64' || fail "x86-64 の ELF でない"
allowed="ld-linux-x86-64.so.2 libc.so.6 libgcc_s.so.1 libm.so.6 libstdc++.so.6"
needed="$(readelf -d "$stage/nene-bolt" | sed -n 's/.*Shared library: \[\(.*\)\]/\1/p' | sort | tr '\n' ' ' | sed 's/ $//')"
for library in $needed; do
    [[ " $allowed " == *" $library "* ]] || fail "宣言していない動的依存: $library"
done
reported="$("$stage/nene-bolt" --version)"
[ "$reported" = "nene-bolt $version" ] || fail "--version が '$reported'（版は $version）"
contents="$(cd "$stage" && find . -mindepth 1 | sort | tr '\n' ' ' | sed 's/ $//')"
[ "$contents" = "./LICENSE ./README.txt ./nene-bolt" ] || fail "同梱物が固定の 3 つと違う: $contents"

# 再現可能な梱包（並び・時刻・持ち主を固定）
tar --sort=name --mtime=@0 --owner=0 --group=0 --numeric-owner -C .release/stage -cf - "$name" | gzip -n -9 > "$out/$name.tar.gz"
(cd "$out" && sha256sum "$name.tar.gz" > SHA256SUMS)
echo "package-release: $out/$name.tar.gz"
echo "package-release: 動的依存 $needed"
cat "$out/SHA256SUMS"

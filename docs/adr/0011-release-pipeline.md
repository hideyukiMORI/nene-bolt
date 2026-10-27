# ADR 0011 — 版の入力は Version.swift の 1 か所、配布物は静的リンクの 1 経路で作り、検査してから梱包する

- 状態: 受理
- 日付: 2026-10-27
- Issue: #13
- 影響する規則: ARC-006 / QLT-011 / QLT-014

## 文脈

兄弟の NeNe Swarm は、同じ経路（Swarm の ADR 0012。元は NeNe Igo の ADR 0012・0013・NeNe Gambit）で v0.1.0 を公開し、
`install.sh` の 1 行からの導入と、照合・展開・実行まで確かめている。施主の決定は、進め方を Swarm と同じにすること（Q7）と、
**Release の公開など外に出る操作は施主の確認を取ること**（Q8）。

## 決定

Swarm の ADR 0012 の決定を、名前を合わせて引き継ぐ。移植元は Swarm のコミット `a660f47` の `eng/package-release.sh`・`eng/release/README.txt`（中身は横スクロールで書き直した）・
`install.sh`・`install.ps1`・README の構成と、証明 P51〜P54。

1. 版の入力は `Sources/nene-bolt/Version.swift` の `Version.current`（`0.1.0`）の 1 か所。`nene-bolt --version` は `nene-bolt <版>` の 1 行を出す（Phase 3-2 から）
2. 配布物は `eng/package-release.sh [v<版>]`（`make release TAG=v<版>`）だけが作る。別のビルドディレクトリ（`.release/build`）で規約検査・release 構成のテスト・
   `--static-swift-stdlib` のビルドを通し、`strip` してから検査する: x86-64 の ELF・動的依存が `ld-linux-x86-64.so.2` `libc.so.6` `libgcc_s.so.1` `libm.so.6` `libstdc++.so.6` の中だけ・
   `--version` が版と一致・タグが版と一致・同梱物が `nene-bolt` `README.txt` `LICENSE` の 3 つと完全一致
3. 梱包は再現できる形（tar の並び・時刻・持ち主を固定・gzip の時刻を入れない）。`SHA256SUMS` をスクリプトが書く
4. `install.sh` は最新の Release（か `NENE_BOLT_VERSION`）を落とし、`SHA256SUMS` で照合してから `~/.local/bin/nene-bolt` に入れる。照合に失敗したら何も入れない
5. `install.ps1` は WSL の中で `install.sh` を実行し、`%LOCALAPPDATA%\nene-bolt\bin\nene-bolt.cmd` を置いてユーザーの PATH に足す
6. 公開は squash 統合後の clean な `main` から同じスクリプトで作り直し、`v<版>` のタグと同名の Release に配布物と `SHA256SUMS` を添付し、再ダウンロードして照合する。
   **公開（タグの push と Release の作成）は外に出る操作なので、施主の確認を取ってから行う**
7. README は英語が正で、`README.ja.md` は です・ます調。画面写真は実機（Windows Terminal）で撮ったものだけを置く（Phase 3-3）

## 強制

- **active**（QLT-014）: 証明 P51（タグの不一致）・P52（静的リンクを外すと Swift のランタイムへの動的依存で落ちる）・P53（余計な同梱物）・P54（`--version` の不一致）
- `install.sh` と `install.ps1` の 1 行からの導入は、Release を公開してから確かめる（未）

## 結果

- 施主の GO があれば、clean な `main` から `make release TAG=v0.1.0` で配布物を作り、Release に載せられる
- 失うもの: 公開のスクリプトは release 構成のテスト（Engine の単調性のテストを含む）を回すので、配布物を作るのに 6 分ほどかかる

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| 公開の経路を一から書く | Swarm（と元の Igo・Gambit）の経路は、静的リンク・動的依存の検査・再現可能な梱包・照合してから入れる導入まで実際の公開で確かめてある |
| 公開のスクリプトでテストを飛ばして速くする | 配布物の元になったソースがテストを通ったことを、配布物を作る経路の中で確かめる。make check の代わりではないが、省かない |
| PR のたびに Release を作る | 外に出る操作は施主の確認を取る（Q8）。配布物を作る経路だけを置き、公開は施主の GO の後 |

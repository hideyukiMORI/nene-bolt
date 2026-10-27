# 単一ゲート（QLT-001）。ローカルと CI はどちらも `make check` だけを呼ぶ。
# 個別のターゲットは反復中の狭い検査として使ってよいが、完了の定義は `make check` だけである。

BASE ?= origin/main
SWIFTLINT := .tools/swiftlint

.PHONY: check bootstrap tools build test smoke format lint conformance conformance-test commits

check: tools build format lint conformance conformance-test test smoke commits
	@echo "make check: 緑"

bootstrap: tools
	git config core.hooksPath .githooks

tools:
	eng/install-tools.sh

build:
	eng/swift-strict.sh swift build

# 多数のゲームを最後まで回す不変条件のテストは重いので、release 構成で回す（ADR 0006。release でも @testable import は効く・ADR 0001 の X-e）。
test:
	eng/swift-strict.sh swift test -c release

# 実行ファイルを疑似端末で動かし、キー（押す・離すの列を含む）と終わり方ごとの端末の復元を見る（FR-08・FR-04b・ADR 0007）。
smoke:
	eng/swift-strict.sh swift build -c release --product nene-bolt
	python3 eng/smoke-terminal.py .build/release/nene-bolt

format:
	eng/swift-sources.sh | xargs -0 swift-format lint --strict --configuration .swift-format

lint:
	eng/lint.sh $(SWIFTLINT) --config .swiftlint.yml

conformance:
	python3 eng/conformance.py

conformance-test:
	python3 -m unittest discover -s eng/tests -q

commits:
	python3 eng/validate-commit-message.py --range "$(BASE)..HEAD"

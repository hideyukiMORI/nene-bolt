# ADR 0003 — ゲートと規約検査は NeNe Swarm から移植し、商標の検査の語を書き直し、証明はこのリポジトリで取り直す

- 状態: 受理
- 日付: 2026-10-27
- Issue: #1
- 影響する規則: QLT-001 / QLT-007 / CNF-001〜CNF-023 / GIT-003

## 文脈

NeNe Swarm（https://github.com/hideyukiMORI/nene-swarm）・NeNe Poker・NeNe Igo・NeNe Reversi・NeNe Gambit は、同じ施主・同じ MIT ライセンス・同じ厳格規約で作った兄弟のリポジトリである。
施主の方針として、兄弟のゲートと規約検査・文書の形・端末と描画の土台・配布の形は、自分たちのコードとして移植してよい。
Swarm は兄弟でいちばん新しく、リアルタイムの設計（Core と Engine は時計を知らない 1 刻み関数・固定小数点の座標・AI は入力だけを返す）まで持っている。
施主の決定は「NeNe Swarm と同様な感じで」（REQUIREMENTS の Q7）。

## 決定

Issue #1 で次のファイルを Swarm の Issue #1 のコミット `14f3283`（Phase 0〜2 の足場の形）から移植した。

| このリポジトリのファイル | 変えたこと |
| --- | --- |
| `eng/conformance.py`・`eng/tests/test_conformance.py` | 名前を合わせた。CNF-001〜CNF-023 の番号と意味は Swarm と同じ。**CNF-023 の語を、参考にした 2 本のゲームの名前・キャラクター名・面の名前・会社名に書き直した**（下） |
| `eng/measure-language.py` | 名前を合わせた。ケースは足していない（ADR 0001） |
| `eng/prove-gates.py` | 名前を合わせた。CNF-023 の証明 P62 の語を替えた。GitHub 側の証明（P43・P46）はこのリポジトリの ruleset と run で書き直す |
| `eng/` のほかのスクリプト・`Makefile`・`Package.swift`・`.swift-format`・`.swiftlint.yml`・`.swift-version`・`.gitignore`・`.githooks/`・`.github/` | 名前を合わせた（target は 0 本。`test`・`smoke` の段はまだ足さない） |
| `docs/` の各文書・`CLAUDE.md`・`AGENTS.md`・`README.md` | 形は Swarm のまま、中身は横スクロールのアクションと施主の決定で書き直した |

### CNF-023 の語

参考にした 2 本のゲームの名前（英語の綴りの揺れと日本語）・主なキャラクター名・施主が挙げた面の名前・会社名。
キャラクター名のような 5〜6 文字の短い語は、ふつうの英単語（`scenario`・`marionette` など）の中で誤って当たらないよう語の切れ目で見る。
一覧は `eng/conformance.py` の `TRADEMARKS` が正本で、検査器自身と単体テストが違反にならないよう、どの語も分割して組み立てる。

持ってこなかったもの: Swarm のゲームの中身（Core と Engine は横スクロールで一から書く）・キャストとセリフ（新しい 4 名で書く）・
端末と描画の土台・smoke・配布（Phase 3〜4 の使う PR で Swarm の main から移植してこの表に足す）。Swarm の作業木には書き込んでいない。

**証明はすべてこのリポジトリで取り直す**（`python3 eng/prove-gates.py`・[gate-proofs.md](../quality/gate-proofs.md)）。兄弟の証明の結果は一つも写さない。

## 強制

- **active**: 移植した検査はすべて、このリポジトリの証明が通ってから強制マトリクスで active にした（CNF-006 が証明行の無い active を拒否する）
- **不能**: 「移植元を理解して写したか」はレビュー事項。CNF-023 は一覧に無い名前（別のキャラクター名・綴りの崩し）を見ない。見つけたら一覧に足す

## 結果

- 7 回分の実測と事故から生まれた検査を、最初から持てる
- 施主の言葉に含まれていた商標の名前は、文書に写す時点で要旨に置き換えた（REQUIREMENTS 冒頭）
- 失うもの: 兄弟の検査器が直されても、このリポジトリには自動では入らない

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| Igo や Poker から移植する | Swarm がそれらを受け継いだうえで、リアルタイムの設計を足している。施主の指定も「Swarm と同様」 |
| Swarm の main（全 target あり）から移植する | 製品のコードまで入ってしまう。Phase 1 は製品のコードを書かない。足場の形の `14f3283` から始め、土台は使う PR で移す |
| 短い語も部分一致で見る | `scenario`・`marionette` のようなふつうの語で誤って落ちる |
| 兄弟の gate-proofs の結果を写す | 設定が在ることは検査が効いている証明ではない（ポリシー P-09） |

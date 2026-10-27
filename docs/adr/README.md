# アーキテクチャ決定記録（ADR）

トレードオフのある判断を、**理由ごと**残す場所。正本ドキュメントが「いま何が規範か」を書くのに対し、
ADR は「なぜそう決めたか」「何を却下したか」を書く。

## 書き方

- 連番 4 桁 ＋ kebab の題名: `NNNN-short-kebab-title.md`
- `0000-template.md` を複製して書く
- 状態は `提案` / `受理` / `却下` / `置換（→ NNNN）`
- **却下した選択肢を必ず書く。** 再提案は、その理由への反論から始めること
- 受理された ADR を後から書き換えない。変えるときは新しい ADR で置き換える
- 文脈は可能な限り実データ（コード・履歴・計測・コンパイラの出力）で裏を取る

## 一覧

| ADR | 題名 | 状態 |
| --- | --- | --- |
| [0001](0001-strictness-is-mechanically-enforced.md) | 厳格さは機械で強制する | 受理 |
| [0002](0002-swift-testing-only.md) | テスト枠組みは Swift Testing だけにする | 受理 |
| [0003](0003-port-gates-from-swarm.md) | ゲートと規約検査は NeNe Swarm から移植し、商標の検査の語を書き直し、証明はこのリポジトリで取り直す | 受理 |
| [0004](0004-target-split-and-dependency-graph.md) | target は Core・Engine・Render・Terminal・合成ルートの 5 つに分け、兄弟と同じ向きで依存させる | 受理 |
| [0005](0005-fixed-point-maps-and-tick-step.md) | 座標は 1 セル 16 単位の整数で持ち、面は文字の地図で書き、ゲームは固定の順番の 1 刻み関数だけで進める | 受理 |
| [0006](0006-invariant-tests-and-measured-runs.md) | 不変条件のテストでゲートを組み、4 面それぞれから release 構成で 600 ゲームを回す | 受理 |
| [0007](0007-terminal-keys-camera-and-first-screen.md) | 端末と描画の土台を Swarm から移し、面の窓をカメラで映し、押す・離すのキー入力で人が割り込めるようにする | 受理 |
| [0008](0008-runners-cast-and-game-length.md) | ランナーは道のりの地図と Core の 1 刻み関数の 2 段の先読みで動き、キャスト 4 名の性格で長さと遊び方を散らす | 受理 |
| [0009](0009-runner-lines-and-comms.md) | キャスト 4 名に 1 人 50 本のセリフを持たせ、80 × 24 では面の窓を 17 段にして COMMS の 1 行を置く | 受理 |

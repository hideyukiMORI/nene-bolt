# ADR 0004 — target は Core・Engine・Render・Terminal・合成ルートの 5 つに分け、兄弟と同じ向きで依存させる

- 状態: 受理
- 日付: 2026-10-27
- Issue: #1
- 影響する規則: ARC-002 / ARC-003 / ARC-006 / ARC-007 / ARC-011 / CNF-010 / CNF-011

## 文脈

依存方向を物理的にする（ARC-002）には、責務ごとに SwiftPM の target を分け、禁じた向きを「import できない」状態にする必要がある。
兄弟の NeNe Gambit・Reversi・Igo・Poker・Swarm は同じ形の製品を 5 つの target で作っている（各リポジトリの ADR 0004）。
Phase 0 の実測で、SwiftPM は兄弟の target の import を拒むが、**推移的な依存の import は拒まない**ことを確かめた（M6-a・M6-e・M6-f）。

NeNe Bolt が Swarm と違うのは、(1) 人が遊べる（キーで割り込む）、(2) 面が端末より広く横に流れる、の 2 点。どちらも層の分け方を変える理由にはならなかった。

- Core: 面の地形・自機・敵・ボス・弾・当たり判定は「状態＋入力＋乱数源 → 次の状態と出来事」の 1 刻み関数で書ける。**入力は人のキーでも AI の判断でも同じ型**
- Engine: ランナーの AI は Core の状態を読んで入力を返すだけ。先読みも Core の 1 刻み関数を通る（Swarm と同じ）
- Render: カメラ（面のどこを映すか）は見た目の判断なので Render に置く
- Terminal: キー入力の解析に、押す・離すを両方受け取る方式（Windows Terminal）を足す。押されているボタンの組への変換は合成ルートが持つ（どちらが操作しているかも合成ルート）

## 決定

依存グラフの正本は `docs/architecture/module-graph.txt` とし、次の 5 つの target とそれぞれのテスト target を承認する。

```text
NeNeBoltCore      面の地形・自機・敵・ボス・弾・当たり判定・拾うもの・スコア・面と中間地点・場面・難易度・入力の型・1 刻み関数（依存なし）
NeNeBoltEngine    ランナーの AI・キャストの性格とセリフ（-> Core）
NeNeBoltRender    ゲームの状態＋HUD の値 → 文字セルの格子（カメラ・背景・演出を含む）（-> Core, Engine）
NeNeBoltTerminal  セル格子 → ANSI の差分出力・termios・シグナル・キー入力（押す・離すを含む）（-> Render ＋ Glibc・unsafe を許す唯一の区画）
nene-bolt         合成ルート。時計・乱数・環境・起動オプション・ハイスコアのファイル・操作している人を持つ唯一の場所。刻みを回す（-> 上の 4 つ ＋ Glibc）
```

- 入力の型（押されているボタンの組）は Core に置く。人のキーと AI の判断は、合成ルートでこの型にそろえてから Core に渡す
- 難易度とテーマの選択と「どちらが操作しているか」は合成ルートが持つ
- target は最初の具体的な責務が生じた PR で `Package.swift` に足す。Phase 1 の `Package.swift` の target は 0 本
- Swarm が Phase 3-2 で足した Terminal の `Synchronization` は、このリポジトリで同じ必要が生じた PR で、この ADR を置き換える ADR とともに足す

## 強制

- **active** → SwiftPM の target グラフ＋CNF-010（`Package.swift` と正本の一致）＋CNF-011（import の許可リスト）＋CNF-012（合成ルート以外で時計・乱数源・`CommandLine`・環境を読まない）

## 結果

- 「Core は時計も端末も知らない」「AI は Core の状態を書き換えない」「人と AI は同じ入力で操作する」が、import の失敗と型で守られる
- 失うもの: Terminal のテストでゲームの状態から格子を作るような便利な書き方はできない

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| 1 つの target にまとめ、ディレクトリで分ける | ディレクトリの命名だけでは依存の境界にならない |
| 人の入力用に別の型を作り、Core に 2 つの入口を置く | 人だけ・AI だけの近道が生まれる（ARC-001）。不変条件の「入力の合法性」も 2 つに割れる |
| カメラを Core に置く | 当たり判定に関係しない値がゲームの状態に入り、決定性のテストが見た目の変更で壊れる（Swarm の ADR 0004・0010 と同じ理由） |
| キー入力をボタンの組に直すのを Terminal に置く | Terminal はゲームを知らない（ARC-011）。キーとボタンの対応は遊びの決まりなので合成ルートに置く |

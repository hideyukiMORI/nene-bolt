# モジュール構成と依存規則 — NeNe Bolt

> Status: normative（規範）/ 2026-10-27 初版
> パッケージ: SwiftPM `NeNeBolt`（`Package.swift`）

モジュールグラフはアーキテクチャの一部である。**ディレクトリの命名規約だけでは依存の境界にならない。**
承認された一覧の機械可読な正本は `docs/architecture/module-graph.txt` で、規約検査が `Package.swift` の宣言と突き合わせる（ARC-002・CNF-010）。

---

## 1. 承認されたモジュール

空の「将来用 target」を作らない。**2026-10-27 時点で `Package.swift` にあるのは `NeNeBoltCore` とそのテスト（Issue #3）だけ**で、下の一覧は「承認された形」である（ADR 0004）。
残りの target は最初の具体的な責務が生じた PR で足す（Phase 3-2 で Engine・Render・Terminal・合成ルートが入る）。

```text
nene-bolt (executable)
    合成ルート。時計・乱数（シード）・環境・起動オプションを読み、Core・Engine・Render・Terminal を組み立てて
    刻みを回す（時計を見て 1 刻み関数を呼び、刻みごとに描く）。テーマ・難易度のキー・ハイスコアのファイルの読み書きを持つ。
    標準入出力への直書きと終了コードを持つ唯一の場所（ARC-006 / ARC-007）

NeNeBoltTerminal
    セル格子 → ANSI の差分出力・termios・SIGWINCH・キー入力の解析。unsafe 系 API を許す唯一の区画（SWF-009）

NeNeBoltRender
    ゲームの状態＋HUD の値 → 文字セルの格子（配色・自機と敵と弾と地形のブロック・横に流れる画面・背景と爆発の演出・HUD・セリフ）。端末を知らない。出力は値

NeNeBoltEngine
    ランナーの AI（跳ぶ・避ける・撃つ・踏む・迷う）・キャストの性格とセリフ。Core の状態を読んで入力だけを返す。乱数は引数で受け取る。時計を知らない

NeNeBoltCore
    面の地形（固い・滑る・梯子・棘・穴・消える足場・動く足場・ベルトコンベア）・自機（体力・残機・パワーアップ）・敵とボス・弾・当たり判定・
    拾うもの・スコア・面と中間地点・場面・難易度の効き方・入力の型・1 刻み関数。時刻・乱数源・端末・Foundation・ファイルを知らない（乱数は引数で受け取る）。値型＋純粋関数
```

テスト target は `<target>Tests`（`NeNeBoltCoreTests` 等）で、Swift Testing だけを import できる（SWF-016）。

---

## 2. 許可された依存グラフ

```text
NeNeBoltCore      -> （無し）
NeNeBoltEngine    -> NeNeBoltCore
NeNeBoltRender    -> NeNeBoltCore, NeNeBoltEngine
NeNeBoltTerminal  -> NeNeBoltRender                         ＋ 標準モジュール Glibc
nene-bolt         -> 上の 4 つすべて（明示的な合成のためだけに） ＋ 標準モジュール Glibc
```

ここに無い依存はすべて禁止である。とくに:

- Core / Engine / Render -> Foundation・FoundationEssentials・Glibc・Dispatch: **禁止**（標準モジュールはビルドグラフでは塞げないので CNF-011 が塞ぐ）
- 宣言していない推移的な依存の import（例: Terminal -> Core）: **禁止**（SwiftPM は拒まない・M6-e。CNF-011 が塞ぐ）
- Core -> Engine、Engine -> Render 等の逆向き: 禁止（SwiftPM が `no such module` で拒み、CNF-010 が宣言を拒む）
- Terminal -> Core / Engine: 禁止（Terminal はセル格子しか知らない）
- 何か -> 合成ルート: 禁止
- Foundation: どの target からも禁止（SWF-014）

---

## 3. 各モジュールの責務

### `NeNeBoltCore`

意味の正本を持つ。場面・難易度・地形の種類・敵の種類・敵の状態・ボスの攻撃・自機の状態・拾うものの種類・入力のボタン・失い方（閉じた enum）。
「当たったか」「ステージを終えたか」「ゲームが終わったか」の経路は Core に 1 つずつ。ゲームを進めるのは 1 刻み関数だけで、
秒を知らない。座標は整数（固定小数点）で、セルへの変換は 1 経路（ADR 0005）。面は文字の地図で埋め込む。乱数源は引数で受け取り、同じシードで同じゲームになる。

### `NeNeBoltEngine`

ランナーの AI（穴と棘と敵の弾を避ける・跳ぶ・撃つ・踏む・消える足場を待つ・迷う）・キャストの性格とセリフ。Core が公開する状態を読み、**入力だけを返す**（Core の状態を書き換えない）。人の入力と同じ型で返す。
先読みに Core の 1 刻み関数を使うのは自由で、第 2 の物理を作らない。乱数は `inout` で受け取った乱数源からだけ引く（CNF-012 は `using:` の無い `random(...)` を拒む）。

### `NeNeBoltRender`

ゲームの状態と HUD の値から文字セルの 2 次元配列を作る。色は Render の配色表だけが持つ。自機・敵・弾・地形・拾うものは地とは別の色で塗った偶数桁のブロックで描き、
それらのセルに文字を書かない（FR-07）。背景の多層のスクロール・爆発・浮かぶ得点・閃光・STAGE とボスの警告の帯もここで値として作る。横に流れる画面のどこを映すか（カメラ）もここで決める。

### `NeNeBoltTerminal`

alternate screen・カーソル非表示・24bit カラー（無ければ 256 色）・前フレームとの差分・1 フレーム 1 回の `write`・SIGWINCH・
**異常終了でも端末を必ず復元**。キー入力を閉じた enum の意図に変える。可変性の隔離区画（ARC-005）。

### `nene-bolt`

依存を結ぶ。「何秒で 1 刻みか」はここが決める。ハイスコアのファイル（FR-02e）を読み書きしてよい唯一の場所。端末出力（起動できなかった理由 1 行）と終了コードを扱ってよい唯一の場所（ARC-006）。

---

## 4. ソースの置き場

| 種類 | 置き場 |
| --- | --- |
| production | `Sources/<target>/`（`path:` で変えない・CNF-009） |
| テスト | `Tests/<target>Tests/`（規約検査の対象。決定性・網羅性の禁止も適用する） |
| 検査設定 | `.swiftlint.yml`・`.swift-format`（直下の 2 つだけ・CNF-007） |
| 規約検査とその単体テスト | `eng/conformance.py`・`eng/tests/` |
| 依存グラフの正本 | `docs/architecture/module-graph.txt` |
| 生成コード | 無い（SwiftPM のビルドプラグインを使わない・SWF-009） |
| 道具の置き場 | `.tools/`（git 管理外。`eng/install-tools.sh` が lock の SHA-256 で入れる） |

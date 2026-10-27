# CLAUDE.md — NeNe Bolt

Claude Code / AI エージェントがこのリポジトリで作業するための**中核ハンドブック**。
簡潔な英語版の入口は [AGENTS.md](AGENTS.md)。詳細の正本は `docs/` にあり、ここには複製しない。

---

## 0. まず読むもの（production コードに触れる前に必ず）

1. [docs/ARCHITECTURE_CONSTITUTION.md](docs/ARCHITECTURE_CONSTITUTION.md) — 憲章（ARC-NNN）
2. [docs/PROJECT_LAYOUT.md](docs/PROJECT_LAYOUT.md) — モジュールと依存方向
3. [docs/CODING_RULES.md](docs/CODING_RULES.md) — Swift 6 規約（SWF-NNN）
4. [docs/QUALITY_GATES.md](docs/QUALITY_GATES.md) — **いま何が機械で守られているか**（QLT-NNN / CNF-NNN）
5. [docs/DEVELOPMENT_WORKFLOW.md](docs/DEVELOPMENT_WORKFLOW.md) — 手順
6. [docs/COMMIT_CONVENTIONS.md](docs/COMMIT_CONVENTIONS.md) — Issue・ブランチ・コミット・PR（GIT-NNN）
7. [docs/GLOSSARY.md](docs/GLOSSARY.md) — 用語
8. 該当する ADR（`docs/adr/`）と有効な waiver（`docs/waivers/`）

---

## 1. このリポジトリの統治原則

> **一つのことを実現する方法を 1 つに固定し、そのことを人の記憶ではなく機械に守らせる。**

その帰結として、次の 3 つを常に守る。

1. **正典の経路を先に特定してから編集する。** 「ここで書いたほうが早いから」で第 2 の経路を作らない（ARC-001 / ARC-012）
2. **ゲートを弱めて通さない。** 検査が落ちたらコードを直す。閾値・除外・重大度を触るのは ADR 相当の判断（QLT-010）
3. **`planned` を `active` と書かない。** 未実装の強制を実装済みに見せるのは、この規約体系で唯一「壊す」行為（[ADR 0001](docs/adr/0001-strictness-is-mechanically-enforced.md)）

---

## 2. このプロジェクトで間違えやすい所

### 公表値が無いので、不変条件でゲートを組む

アクションゲームには perft や役の数のような公表値が無い。正しさは REQUIREMENTS 第 3 節の不変条件（決定性・範囲（地形に埋まらない）・
当たり判定（床を突き抜けない）・消える足場・数の保存・場面の遷移・必ず終わる・難易度の単調性・入力の合法性・人と AI の入れ替わり）をテストで守って確かめる。
**ゲートで回すシードの数や件数を黙って下げない**（下げるなら ADR）。重いテストは release 構成で回す（X-e）。

### Core と Engine は時計を知らない

ゲームは「状態＋入力 → 次の状態」を 1 刻み進める純粋な関数で、何秒経ったかは合成ルートだけが知る。
Core と Engine に「秒」「ミリ秒」を持ち込まない。速さは「1 刻みに何単位進むか」で書く。刻みを回して描くのは合成ルートの 1 本のループだけ。

### 座標は整数（固定小数点）

位置と速さはセルを細かく割った整数で持つ。🔴 `Double.squareRoot()` は libm の `sqrt` を呼び、標準モジュールを import しない実行ファイルでは
**debug でも release でもリンクできない**（ADR 0001 の X-i・X-j）。重力と跳躍の放物線も整数で描く。
負の数の `/` は 0 に向かって切り捨て、`>>` は負の無限大に向かって丸める（X-k・X-l）。どちらを使うかで座標が 1 単位ずれるので、セルへの変換は 1 経路にまとめる。
`Int32` の `+` は `-O` でも桁あふれで落ちる（X-m）。乱数の掛け算は `&*` で書く（X-g・X-h）。

### 当たり判定・ステージ終了・ゲーム終了は Core の 1 経路だけ

「当たったか」「ステージを終えたか」「ゲームが終わったか」の経路は Core に 1 つずつ（ARC-001）。
ランナーの AI（Engine）は Core が公開する状態を読み、**入力だけを返す**。Core の状態を書き換えない。
先読みに Core の 1 刻み関数を使うのは自由で、速さのために第 2 の物理を書かない。🔴 速く落ちて 1 刻みで床を突き抜ける罠と、速い弾が敵を飛び越える罠はテストで塞ぐ。

### 人と AI は同じ入力の型で操作する

人のキー入力も AI の判断も、Core に渡るのは同じ 1 つの入力の型（押されているボタンの組）で、同じ経路を通る。人だけの近道・AI だけの近道を作らない。
どちらが操作しているかは合成ルートだけが持つ（FR-04a）。

### 端末は「キーを離した」を教えてくれない

ふつうの端末に届くのは押したときの文字とキーのくり返しだけで、離したことは届かない。Windows Terminal には押す・離すを両方送るモードがあるので、
それを使い、使えない端末では「くり返しが届いている間は押している」とみなす簡易な方式に落とす（FR-04b）。どちらの方式でも Core に渡る入力の型は同じ。

### 商標の名前を書かない

参考にしたゲームの名前・キャラクター名・面の名前・会社名は、製品名・README・コード・コメント・セリフのどこにも書かない（FR-17・CNF-023）。
「横スクロールのアクション（side-scrolling platformer）」と書く。自機・敵・ボス・地形の形は新しく描き、既存のゲームの絵や曲を写さない。

### 文字幅と字形は実機の画面写真で確かめる

自機・敵・弾・地形・拾うものは地とは別の色で塗った偶数桁のブロックで描き、それらのセルに文字を書かない（FR-07）。
Emoji=Yes の文字は前景色が効かない（Gambit ADR 0013）。半ブロック `▀` `▄` を使うなら、1 桁で描かれ 2 色が正しく出ることを実機で確かめてから採る。

### 現在時刻・乱数・環境を読む場所は 1 つしかない

時計・乱数・環境変数・起動オプション（`CommandLine`）を読んでよいのは **合成ルート `nene-bolt`** だけである（ARC-007）。
Swift ではどれも標準ライブラリだけで書けてしまう（`Int.random`・`ContinuousClock.now`・`CommandLine.arguments`・`Task.sleep`）ので、
規約検査（CNF-012・CNF-022）が字句で落とす。乱数が要る関数は乱数源を `inout` で受け取り、`random(in:using:)` のように `using:` を付けて呼ぶ。
**テストにも同じ禁止がかかる。**

### 網羅性検査を殺す分岐を書かない

`switch` に `default:` / `@unknown default` / `case _:` / `case let x:` を書かない。**括弧で包んだ `case (let x):`・並べた `case .a, _:`・
全位置が `_` のタプル `case (_, _):` も同じ全捕捉**で、コンパイラは何も言わない（M1-j・M1-k・M1-m）。CNF-013 が `case` の選択肢を 1 つずつ見て落とす。
既知ケースを漏らす `@unknown default` は警告エラーでも warning のまま通ってしまう（M1-e）。選択肢が増えたらコンパイルが落ちるのが正しい状態。
閉じた enum を `==` と `else` で分岐すると網羅性が無くなるが、これは機械では塞げない（M1-i）。閉じた enum は `switch` で分岐する。

### 文字列で分岐するなら `if`

`switch` を `String` や `Int` に使うと全捕捉が要るが、全捕捉は CNF-013 が落とす（証明 P50 では `case _ where true:` もコンパイラが網羅に数えなかった）。
文字列や整数での分岐は `if` で書くか、閉じた enum に直してから `switch` する。

### `init` は型の本体にだけ書く

`private init` は、同じ target の別ファイルの `extension` に `init` を足すと格納プロパティを直接埋めて迂回できる（M4-f）。
`extension` に `init` を書かない（CNF-021）。別の表現から作る経路は、型の本体の `static func`（結果型を返す唯一のファクトリ）にする。

### 警告のエラー化は `Package.swift` にある

target を足すときは `swiftSettings: [.treatAllWarnings(as: .error), .enableUpcomingFeature("ExistentialAny")]` を必ず付ける（CNF-009）。
コマンド行の `-Xswiftc -warnings-as-errors` は manifest の設定に負ける（M8-h）ので、そこに頼らない。
`@preconcurrency import` は並行性の error を、警告エラーでも戻らない warning に下げる（M7-i）ので書かない（CNF-014）。

### 依存の依存は import できてしまう

SwiftPM は、宣言していない**推移的な**依存の import を拒まない（M6-e。`--explicit-target-dependency-import-check error` でも通る・M6-f）。
target が import してよいのは、依存グラフの正本で宣言した直接の依存と標準モジュールだけで、CNF-011 が字句で見る。

### 期待される失敗は例外にしない

読めない起動オプション・合法でない入力などは閉じた enum の結果型で返す。製品コードに `throw` / `try` / `catch` を書かない（ARC-010 / SWF-005・CNF-019）。

### 並行性は使わない

どの target でも `async` / `await` / `Task` / `actor` / スレッド / Dispatch を書かない（SWF-013・CNF-022）。待つのは合成ルートの 1 本のループだけ。

### SwiftPM 自身の警告も失敗になる

`eng/swift-strict.sh` が `swift build` の出力の `warning:` を見て落とす。テスト target を足したらソースも同じ PR で足す（空のテスト target は警告になる）。

### SwiftLint は静的バイナリ

動的バイナリは glibc 2.35 では起動しない（NeNe Gambit の実測）。`make bootstrap`（または `make check` の `tools` 段）が `.tools/swiftlint` に静的バイナリを入れる。

## 3. 検証コマンド

```bash
make bootstrap      # clone 直後に 1 回（コミットフックと SwiftLint）
make check          # 唯一の完了定義（ローカルと CI で同じ）
```

開発中は最も狭い検査を使ってよい。フルゲートは **PR を Draft → Ready にする直前**に必ず通す。

🔴 **`make check` が通っていないものを「できた」と報告しない。**
実行していないコマンドの結果を書かない。テストの失敗を隠さない。
テストが本当の欠陥を見つけたら、期待値ではなく production コードを直す。

---

## 4. 変更の進め方

[docs/DEVELOPMENT_WORKFLOW.md](docs/DEVELOPMENT_WORKFLOW.md) が正本。要約すると:

Issue → 正典経路の特定 → ブランチ → （設計を変えるなら先に ADR）→ 最小の実装 →
テスト → 狭い検査 → `make check` → 規則 ID ごとの自己レビュー → PR（draft）→ Ready → squash merge。

コミットは Conventional Commits（`type` と `scope` は英語、説明は日本語、末尾に `(#N)`）。形の正本は GIT-003。

---

## 5. 完了報告の形

作業を終えたら必ず次を報告する。

```text
Issue / 規則 ID:
変更したファイルと振る舞い:
実行した検証コマンドと結果:
ドキュメント・スキーマの変更:
Waivers: none | WVR-NNNN
残るリスク:
```

調査だけを頼まれたときは、編集・コミット・push・PR 作成・外部状態の変更を行わない。

---

## 6. いまの状況

現在のタスクは [docs/todo/current.md](docs/todo/current.md)。GitHub Issue が正で、そこは要約。

- 動くもの: `make check`（smoke を含む）・`nene-bolt`（仮のランナーが TITLE → PLAY → GAME OVER / ENDING を 80 × 24 で遊び続け、遊びのキーで人が割り込み 30 秒で AI に戻る・
  横に流れる面をカメラで映す・Windows Terminal の押す・離すの方式と簡易な方式・ADR 0005〜0007）
- 動かないもの: Windows Terminal の実機での確認（Phase 3-3）・本物のランナーとキャストとセリフ（Phase 3-4）・専用の色と演出と大きな端末の配置（Phase 3-5）
- 施主の決定は [docs/REQUIREMENTS.md](docs/REQUIREMENTS.md) にそろっている。決定を覆したくなった点や、要件に無い機能を足したくなった点は、自分で決めずに施主に聞く

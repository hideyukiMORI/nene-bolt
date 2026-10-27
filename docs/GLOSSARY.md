# 用語集 — NeNe Bolt

> Status: normative（規範）/ 2026-10-27 初版
> ここに載っている語は、コード・ドキュメント・Issue で**同じ意味**で使う。同義語を発明しない。

| 語 | 意味 | 型／場所 |
| --- | --- | --- |
| 結果（outcome） | 期待される成功・失敗を表す閉じた型 | `*Outcome` |
| 拒否理由（rejection / failure） | 結果に添える閉じた理由の集合 | `*Rejection` / `*Failure` |
| 合成ルート | 依存を結ぶ唯一の場所。時計・乱数・環境を読み、標準入出力と終了コードを持つ | `nene-bolt`（executable target） |
| 描画（render） | ゲームの状態と HUD の値から文字セルの格子という値を作ること。端末への書き出しは含まない | `NeNeBoltRender` |
| 隔離区画 | 可変性を許した唯一の場所 | ARC-005 の表 |
| 規約検査（conformance） | NeNe Bolt 固有の自作ゲート | `eng/conformance.py`（CNF-NNN） |
| waiver | 1 つの規則に対する期限付きの狭い例外 | `docs/waivers/WVR-NNNN-*.md` |
| 機械強制の状態 | active / planned / 不能 / 不採用 | `docs/QUALITY_GATES.md` の強制マトリクス |
| negative proof | ゲートが意図した規則で落ちることの実測 | `docs/quality/gate-proofs.md` |
| 横スクロールのアクション（side-scrolling platformer） | このゲームの種類。自機は面を左から右へ走り、跳び、撃つ。画面は自機に合わせて横に流れる。参考にしたゲームの名前は書かない（FR-17・CNF-023） | — |
| 刻み（tick） | ゲームを 1 段進める単位。Core と Engine は刻みの数だけを知り、秒を知らない。何秒で 1 刻みかは合成ルートだけが決める | `NeNeBoltCore`・合成ルート |
| 1 刻み関数（step） | 「状態＋入力＋乱数源 → 次の状態と出来事」の純粋な関数。ゲームを進める唯一の経路 | `NeNeBoltCore` |
| 入力（input） | 1 刻みに押されているボタンの組（左・右・上・下・跳ぶ・撃つ）。人のキーも AI の判断もこの型で Core に渡る | `NeNeBoltCore` |
| 操作する人（controller） | いま入力を出しているのが AI か人か。遊びのキーで人に替わり、決めた秒数押さなければ AI に戻る（FR-04a） | 合成ルート |
| キー入力の方式（key mode） | 押す・離すを両方受け取る方式（Windows Terminal）と、キーのくり返しを押しているとみなす簡易な方式（FR-04b） | `NeNeBoltTerminal`・合成ルート |
| 面（stage） | 4 つの面の 1 つ。決まった地形と、敵の出方・中間地点・ゴール（4 面はボスの部屋）を持つ（FR-02a） | `NeNeBoltCore` |
| 地形（terrain） | 面のセルの種類: 空き・固い・滑る・梯子・棘・消える足場・ベルトコンベアなど。閉じた enum | `NeNeBoltCore` |
| 消える足場（vanishing block） | 決まった間隔で順に現れては消える足場。消えている間は乗れない（FR-02b） | `NeNeBoltCore` |
| 自機（runner） | 操作する人か AI が動かすキャラクター。体力・残機・パワーアップの段・コインを持つ | `NeNeBoltCore` |
| 体力（health） | 被弾で減るゲージ。尽きたら 1 機失う。穴と棘は体力によらず 1 機失う（FR-02d） | `NeNeBoltCore` |
| 溜め撃ち（charge shot） | 撃つボタンを押し続けて溜め、離して出す大きな弾 | `NeNeBoltCore` |
| パワーアップ（power-up） | 撃つ弾を強くする段。拾うと 1 段上がり、被弾すると 1 段戻る（FR-02e） | `NeNeBoltCore` |
| 敵の種類（enemy kind） | 歩く・跳ねる・飛ぶ・砲台・面ごとの変わり種。踏めるかどうかと得点の表の持ち主。閉じた enum | `NeNeBoltCore` |
| ボス（boss） | 4 面の終わりの部屋の大きな敵。体力のゲージと攻撃の型を持つ（FR-02c） | `NeNeBoltCore` |
| 中間地点（checkpoint） | 1 機失ったときに戻る面の途中の位置 | `NeNeBoltCore` |
| 拾うもの（pickup） | コイン・体力の回復・1UP・パワーアップ。閉じた enum | `NeNeBoltCore` |
| カメラ（camera） | 面のどこを画面に映すか。自機に合わせて横に流れる。Render が決める | `NeNeBoltRender` |
| 難易度（difficulty） | EASY・NORMAL・HARD。敵の側（数・速さ・弾・ボスの体力）だけを変える（FR-14） | `NeNeBoltCore` |
| 出来事（event） | 1 刻みで起きたこと（倒した・踏んだ・拾った・被弾した・落ちた・面を終えた・ボスを倒した…）。セリフと演出の入力 | `NeNeBoltCore` |
| ランナー（runner AI）・性格（persona） | AI で走る 4 名のキャラクター。走り方・撃ち方・踏み方・迷い・セリフの組（FR-04・FR-06） | `NeNeBoltEngine` |
| 先読み（rollout） | ランナーが動きを Core の 1 刻み関数でそのまま進めてみること。動き＋続きの 2 段（ADR 0008） | `NeNeBoltEngine`（`Rollout`） |
| 道のりの地図（route） | 立てる所を点にし、歩く・梯子・跳ぶ・落ちるでつないで数えた、行き先までの重みの和。ランナーの「近づく向き」の目安（ADR 0008） | `NeNeBoltEngine`（`Graph`・`Route`） |
| ハイスコア（high scores） | 上位 5 件。読み書きは合成ルートだけ（FR-02g） | 合成ルート・`NeNeBoltCore`（並べ方） |
| シード（seed） | 自前の PRNG の初期値。同じシード・キー入力なしなら同じゲームの列と同じセリフ | 合成ルートが読み、Core と Engine に渡す |
| セル格子 | 端末の 1 画面分の文字セルの 2 次元配列。Render が作り、Terminal が差分で書く | `NeNeBoltRender` |
| 面の窓（view） | 画面に映す面の範囲。39 セル × 18 段（端末の 78 桁 × 18 行）。どこを映すかはカメラが決める（ADR 0007） | `NeNeBoltRender`（`Camera`・`ScreenLayout`） |
| 押す・離すの方式（press and release） | Windows Terminal の win32-input-mode。キーを押したときと離したときの両方が届く。応じない端末は簡易な方式（キーのくり返し）に落ちる（FR-04b） | `NeNeBoltTerminal`（`KeyDecoder`・`HeldKeys`） |
| 割り込み（take over） | 遊びのキーを押した瞬間から人の操作になること。決めた秒数押さなければ AI に戻る（FR-04a） | 合成ルート（`Controls`） |

## 使ってはいけない語

`Manager` / `Helper` / `Util` / `Utils` / `Common` を型名の語尾に使わない（SWF-010）。
役割を語る名前が思いつかないときは、その型が 2 つの責務を持っている可能性が高い。

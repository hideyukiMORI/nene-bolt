# いまのタスク — NeNe Bolt

> GitHub Issue が正。ここは要約であり、Markdown のチェックリストをタスク状態として扱わない。
> 更新は実測でだけ行う（「動くもの」は `make check` が通ったもの）。

## 段階

| 段階 | 状態 |
| --- | --- |
| Phase 0 言語の実測 | ✅ 2026-10-27（82 ケース・Swarm の 82 ケースと全件一致・ADR 0001） |
| Phase 1 文書とゲートの足場 | ✅ 2026-10-27（Issue #1・PR #2・ruleset 25935437） |
| Phase 2 negative proof | ✅ 2026-10-27（Issue #1 で 60 件・Issue #3 で 61 件すべて pass・GitHub 側 2 件・docs/quality/gate-proofs.md） |
| Phase 3-1 ゲームの進行と当たり判定（Core・画面なし） | ✅ 2026-10-27（Issue #3・ADR 0005 / 0006・不変条件 600 ゲーム） |
| Phase 3-2 端末に描き、人が遊べるようにする | ✅ 2026-10-27（Issue #5・ADR 0007・smoke） |
| Phase 3-3 Windows Terminal の実機で確かめる（画面写真・押す・離す） | 🔲 施主の手番を含む |
| Phase 3-4 本物のランナー 4 名・1 ゲームの長さ | ✅ 2026-10-27（Issue #7・ADR 0008・NORMAL 平均 4 分 24 秒） |
| Phase 3-4b セリフ（1 人 50 本）と COMMS | ✅ 2026-10-27（Issue #9・ADR 0009） |
| Phase 3-5 面ごとの色・背景・演出・大きな端末の配置 | ✅ 2026-10-27（Issue #11・ADR 0010） |
| Phase 4 公開の経路（make release・install.sh・install.ps1・README） | ✅ 2026-10-27（Issue #13・ADR 0011） |
| Phase 4 Release の公開 | ✅ 2026-10-27 v0.1.0（ベータ・Q14・commit 20ebd32・SHA-256 f1da40a6…f2d6） |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・`swift test -c release`・smoke・コミットの形）
- `nene-bolt`: 80 × 24 の画面・カメラ・HUD・キャスト 4 名のランナー（2 段の先読み）・遊びのキーで人が割り込み 30 秒で AI に戻る・押す・離すの方式と簡易な方式・ハイスコアのファイル
- Core: 4 面の地図・走る・跳ぶ（押す長さで高さ）・撃つ・溜め撃ち・踏む・梯子・氷・コンベア・動く足場・消える足場・棘と穴・敵 6 種・拾うもの・中間地点・ゴール・制限時間・ボス戦・場面・難易度・ハイスコアの並べ方

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（ruleset の読み戻しと PR の `BLOCKED` で代えた・gate-proofs 第 4 節）
- Windows Terminal の実機での確認（win32-input-mode が WSL の中まで届くか・ちらつき・見え方）
- テストのランナーはボスまで届かない。ボス戦は手で作った場面でだけ見ている（ADR 0006）

## 次の 1 手

施主に Windows Terminal で遊んでもらい（`install.sh` の 1 行で入る）、`KEYS PRESS/RELEASE` か `KEYS REPEAT` か・見え方・ちらつきを確かめる（Phase 3-3）。
実機の画面写真を README の先頭に置く。

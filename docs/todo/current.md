# いまのタスク — NeNe Bolt

> GitHub Issue が正。ここは要約であり、Markdown のチェックリストをタスク状態として扱わない。
> 更新は実測でだけ行う（「動くもの」は `make check` が通ったもの）。

## 段階

| 段階 | 状態 |
| --- | --- |
| Phase 0 言語の実測 | ✅ 2026-10-27（82 ケース・Swarm の 82 ケースと全件一致・ADR 0001） |
| Phase 1 文書とゲートの足場 | 🔄 Issue #1 |
| Phase 2 negative proof | 🔄 Issue #1 |
| Phase 3 縦切り（ゲームの進行と当たり判定から） | 🔲 別 Issue |
| Phase 4 公開 | 🔲 別 Issue |

## 動くもの

- `make check`（道具の版・`swift build`・整形・lint・規約検査とその単体テスト・コミットの形）。target は 0 本で、製品コードは無い

## 動かないもの

- `main` への直接 push・force push が拒まれることは試していない（ruleset の読み戻しと PR の `BLOCKED` で代えた・gate-proofs 第 4 節）
- 製品そのもの（ゲームの進行・当たり判定・ランナー・描画・端末・人の操作は Phase 3）
- `swift test`（テスト target が無いので結線していない・ADR 0002）

## 次の 1 手

Issue #1 を閉じたあと、Phase 3-1「ゲームの進行と当たり判定（Core だけ・画面なし）」の Issue を立てる。
最初に座標・重力・跳躍・地形のセルと、面の持ち方を ADR で決め、REQUIREMENTS 第 3 節の不変条件をテストにする。全部緑になるまで画面に入らない。

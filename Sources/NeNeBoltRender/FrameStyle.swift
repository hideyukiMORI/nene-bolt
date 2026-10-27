/// 枠と棒グラフの字形の組（ADR 0007）。移植元: NeNe Swarm（コミット a660f47）経由で NeNe Igo `Sources/NeNeIgoRender/FrameStyle.swift`（コミット 3bdae35。Igo は NeNe Reversi の 0ee4526 から移植した）。
public enum FrameStyle: Sendable, Hashable {
    /// 罫線とブロック（`┌─┤│█░▌`）。施主の選んだ形。端末がこれを 1 桁で描くときだけ使う
    case boxDrawing
    /// ASCII（`+-|#->`）。罫線が 2 桁で描かれる端末へ自動で落とす先
    case ascii
}

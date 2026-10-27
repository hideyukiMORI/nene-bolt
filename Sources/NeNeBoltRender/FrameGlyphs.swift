/// 枠の字形（`FrameStyle` ごと）。移植元: NeNe Swarm（コミット a660f47）経由で NeNe Igo `Sources/NeNeIgoRender/FrameGlyphs.swift`（コミット 3bdae35。Igo は NeNe Reversi の 0ee4526 から移植した）。
struct FrameGlyphs: Sendable, Hashable {
    let topLeft: String
    let topRight: String
    let teeLeft: String
    let teeRight: String
    let bottomLeft: String
    let bottomRight: String
    let horizontal: String
    let vertical: String
    let barFull: String
    let barEmpty: String
    let barOpen: String
    let barClose: String
    /// 行頭の印（COMMS の話し手・HUD の題）。
    let marker: String
    /// LOG の手番のカーソル。
    let cursor: String

    static func of(_ style: FrameStyle) -> FrameGlyphs {
        switch style {
        case .boxDrawing:
            return FrameGlyphs(
                topLeft: "┌", topRight: "┐", teeLeft: "├", teeRight: "┤", bottomLeft: "└", bottomRight: "┘",
                horizontal: "─", vertical: "│", barFull: "█", barEmpty: "░", barOpen: "▕", barClose: "▏", marker: "▌",
                cursor: "▌")
        case .ascii:
            return FrameGlyphs(
                topLeft: "+", topRight: "+", teeLeft: "+", teeRight: "+", bottomLeft: "+", bottomRight: "+",
                horizontal: "-", vertical: "|", barFull: "#", barEmpty: "-", barOpen: "[", barClose: "]", marker: ">",
                cursor: "_")
        }
    }
}

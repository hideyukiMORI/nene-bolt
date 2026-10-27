/// 端末の文字セル 1 つ。1 つの `Character` が 1 桁を占めると前提する（ADR 0007）。
///
/// 移植元: NeNe Swarm（コミット a660f47）経由で NeNe Igo `Sources/NeNeIgoRender/`（コミット 3bdae35）の同名の型（Cell・CellColors・ColorMode・Grid・Rgb・ScreenSize・Segment・
/// FrameStyle・FrameGlyphs・Panel・TerminalTraits・DisplayOptions）。Igo の石の下線（CellStyle）は落とした。
///
/// 自機・敵・弾・地形・拾うもののセルは空白で、背景色だけがその色になる（FR-07）。
public struct Cell: Sendable, Hashable {
    public let character: Character
    public let foreground: Rgb
    public let background: Rgb
}

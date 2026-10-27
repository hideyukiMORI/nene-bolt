/// 画面の状態と端末の大きさから、1 画面分のセルの格子を作る（ARC-011: 値を作るだけで端末を知らない）。
public enum ScreenRenderer {
    /// 画面がちょうど入る大きさ（これより小さければ 1 行の文言だけ）。
    public static let minimumSize = ScreenLayout.size

    /// 1 画面分の格子。
    public static func render(_ state: ScreenState, size: ScreenSize) -> Grid {
        let theme = state.display.theme
        var grid = Grid.filled(size, with: Cell(character: " ", foreground: theme.text, background: theme.ground))
        guard size.columns >= minimumSize.columns, size.rows >= minimumSize.rows else {
            grid.write(
                Wording.tooSmall(need: minimumSize), column: 0, row: 0,
                colors: CellColors(foreground: theme.text, background: theme.ground))
            return grid
        }
        draw(state, into: &grid)
        return grid
    }

    private static func draw(_ state: ScreenState, into grid: inout Grid) {
        let theme = state.display.theme
        let glyphs = FrameGlyphs.of(state.display.traits.frame)
        band(row: 0, theme: theme, into: &grid)
        grid.write(ScreenChrome.header(state, glyphs: glyphs), column: 0, row: 0, background: theme.panel)
        frame(glyphs: glyphs, theme: theme, into: &grid)
        StagePainter.clear(theme: theme, into: &grid)
        let cards = FieldCards(theme: theme)
        switch state.session.scene {
        case .title:
            cards.title(state, into: &grid)
        case .play(let game):
            StagePainter(theme: theme, camera: Camera.following(game)).draw(game, into: &grid)
            cards.overlay(game, into: &grid)
        case .gameOver(let summary, _), .ending(let summary, _):
            cards.summary(summary, highScores: state.highScores, into: &grid)
        }
        for (offset, line) in HudStrip(state: state, glyphs: glyphs).lines().enumerated() {
            grid.write(line, column: 0, row: ScreenLayout.hudRow + offset, background: theme.ground)
        }
        band(row: ScreenLayout.footerRow, theme: theme, into: &grid)
        grid.write(ScreenChrome.footer(state), column: 0, row: ScreenLayout.footerRow, background: theme.panel)
    }

    /// 面の窓を囲む枠。
    private static func frame(glyphs: FrameGlyphs, theme: Theme, into grid: inout Grid) {
        let colors = CellColors(foreground: theme.frame, background: theme.ground)
        let across = String(repeating: glyphs.horizontal, count: ScreenLayout.fieldWidth)
        let left = ScreenLayout.fieldColumn - 1
        grid.write(glyphs.topLeft + across + glyphs.topRight, column: left, row: ScreenLayout.frameTop, colors: colors)
        grid.write(
            glyphs.bottomLeft + across + glyphs.bottomRight, column: left, row: ScreenLayout.frameBottom,
            colors: colors)
        for row in ScreenLayout.fieldRow..<ScreenLayout.frameBottom {
            grid.write(glyphs.vertical, column: left, row: row, colors: colors)
            grid.write(
                glyphs.vertical, column: ScreenLayout.fieldColumn + ScreenLayout.fieldWidth, row: row, colors: colors)
        }
    }

    private static func band(row: Int, theme: Theme, into grid: inout Grid) {
        grid.paint(column: 0, row: row, width: grid.size.columns, color: theme.panel)
    }
}

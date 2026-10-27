import NeNeBoltCore

/// 画面の状態と端末の大きさから、1 画面分のセルの格子を作る（ARC-011: 値を作るだけで端末を知らない）。
public enum ScreenRenderer {
    /// 画面がちょうど入る大きさ（これより小さければ 1 行の文言だけ）。
    public static let minimumSize = ScreenLayout.compact.size
    /// 広い配置がちょうど入る大きさ。
    public static let largeSize = ScreenLayout.large.size

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
        let fitsLarge = size.columns >= largeSize.columns && size.rows >= largeSize.rows
        draw(state, layout: fitsLarge ? .large : .compact, into: &grid)
        return grid
    }

    private static func draw(_ state: ScreenState, layout: ScreenLayout, into grid: inout Grid) {
        let theme = state.display.theme
        let glyphs = FrameGlyphs.of(state.display.traits.frame)
        let brush = FieldBrush(layout: layout)
        band(row: 0, theme: theme, into: &grid)
        grid.write(ScreenChrome.header(state, glyphs: glyphs), column: 0, row: 0, background: theme.panel)
        frame(layout, glyphs: glyphs, theme: theme, into: &grid)
        let cards = FieldCards(theme: theme, brush: brush)
        switch state.session.scene {
        case .title:
            clear(brush, theme: theme, into: &grid)
            cards.title(state, into: &grid)
        case .play(let game):
            let camera = Camera.following(game, layout: layout)
            let palette = StagePalette.make(theme: theme, stage: game.stage.kind)
            Backdrop(theme: theme, palette: palette, camera: camera, brush: brush)
                .draw(stage: game.stage.kind, flashing: isFlashing(game), into: &grid)
            StagePainter(theme: theme, palette: palette, camera: camera, brush: brush).draw(game, into: &grid)
            cards.overlay(game, effects: state.effects, camera: camera, into: &grid)
        case .gameOver(let summary, _), .ending(let summary, _):
            clear(brush, theme: theme, into: &grid)
            cards.summary(summary, highScores: state.highScores, into: &grid)
        }
        for (offset, line) in HudStrip(state: state, glyphs: glyphs).lines().enumerated() {
            grid.write(line, column: 0, row: layout.hudRow + offset, background: theme.ground)
        }
        for (offset, line) in ScreenChrome.comms(state, glyphs: glyphs, rows: layout.commsRows).enumerated() {
            grid.write(line, column: 0, row: layout.commsRow + offset, background: theme.ground)
        }
        band(row: layout.footerRow, theme: theme, into: &grid)
        grid.write(ScreenChrome.footer(state), column: 0, row: layout.footerRow, background: theme.panel)
    }

    /// ボスが光る攻撃の間、窓が光る（FR-02c・FR-02h）。
    private static func isFlashing(_ game: Game) -> Bool {
        guard case .fighting(let boss) = game.boss, case .flash = boss.attack else {
            return false
        }
        return game.tick % 4 < 2
    }

    private static func clear(_ brush: FieldBrush, theme: Theme, into grid: inout Grid) {
        let layout = brush.layout
        brush.paint(
            FieldArea(column: 0, row: 0, width: layout.fieldWidth, height: layout.fieldHeight), color: theme.ground,
            into: &grid)
    }

    /// 面の窓を囲む枠。
    private static func frame(_ layout: ScreenLayout, glyphs: FrameGlyphs, theme: Theme, into grid: inout Grid) {
        let colors = CellColors(foreground: theme.frame, background: theme.ground)
        let across = String(repeating: glyphs.horizontal, count: layout.fieldWidth)
        let left = layout.fieldColumn - 1
        grid.write(glyphs.topLeft + across + glyphs.topRight, column: left, row: layout.frameTop, colors: colors)
        grid.write(
            glyphs.bottomLeft + across + glyphs.bottomRight, column: left, row: layout.frameBottom, colors: colors)
        for row in layout.fieldRow..<layout.frameBottom {
            grid.write(glyphs.vertical, column: left, row: row, colors: colors)
            grid.write(glyphs.vertical, column: layout.fieldColumn + layout.fieldWidth, row: row, colors: colors)
        }
    }

    private static func band(row: Int, theme: Theme, into grid: inout Grid) {
        grid.paint(column: 0, row: row, width: grid.size.columns, color: theme.panel)
    }
}

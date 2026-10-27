import NeNeBoltCore

/// 面の窓の中に出す文字（TITLE・GAME OVER・ENDING・面の帯）。文字は地の上に書き、塗ったセルには書かない。
struct FieldCards {
    let theme: Theme
    let brush: FieldBrush

    /// TITLE: 題・ひとこと・ハイスコアの上位 5 件・次のゲーム・割り込みの案内。
    func title(_ state: ScreenState, into grid: inout Grid) {
        big(Wording.bigTitle, top: 1, color: theme.accent, into: &grid)
        center(Wording.tagline, row: 7, color: theme.dim, into: &grid)
        center(Wording.highScores, row: 8, color: theme.accentAlt, into: &grid)
        for rank in 0..<HighScoreTable.capacity {
            center(FieldCards.line(rank, state.highScores), row: 9 + rank, color: theme.text, into: &grid)
        }
        let next =
            Wording.game(state.gameNumber) + "   " + Wording.difficulty(state.difficulty) + "   "
            + Wording.nextRunner(state.pilot)
        center(next, row: 14, color: theme.text, into: &grid)
        center(Wording.takeOver, row: 15, color: theme.dim, into: &grid)
        switch state.storage {
        case .file: break
        case .memoryOnly: center(Wording.memoryOnly, row: 16, color: theme.dim, into: &grid)
        }
    }

    /// GAME OVER と ENDING: 大きな文字・終わり方・最終スコア・到達した面・新記録。
    func summary(_ summary: GameSummary, highScores: HighScoreTable, into grid: inout Grid) {
        let headline: String
        switch summary.ending {
        case .cleared: headline = Wording.allClear
        case .outOfLives, .timeLimit: headline = Wording.gameOver
        }
        big(headline, top: 2, color: theme.accentAlt, into: &grid)
        center(Wording.ending(summary.ending), row: 9, color: theme.dim, into: &grid)
        center("SCORE " + Wording.digits(summary.score, 7), row: 11, color: theme.text, into: &grid)
        let reached = Wording.stageBanner(summary.stage) + "  " + Wording.stageName(summary.stage)
        center(reached, row: 12, color: theme.text, into: &grid)
        if summary.score > 0, highScores.best == summary.score {
            center(Wording.newRecord, row: 14, color: theme.accent, into: &grid)
        }
    }

    /// 遊んでいる間の帯（面の始まり・ゴール・ボスを倒した・急かす・ボスの前の WARNING）と、倒した場所に浮かぶ得点（FR-02h）。
    func overlay(_ game: Game, effects: Effects, camera: Camera, into grid: inout Grid) {
        popups(effects, camera: camera, into: &grid)
        if effects.showsWarning {
            if effects.clock % 20 < 14 {
                big(Wording.warning, top: 4, color: theme.danger, into: &grid)
            }
            return
        }
        switch game.phase {
        case .intro:
            big(Wording.stageBanner(game.stage), top: 4, color: theme.spark, into: &grid)
            center(Wording.stageName(game.stage), row: 11, color: theme.text, into: &grid)
        case .cleared:
            big(Wording.stageClear, top: 4, color: theme.spark, into: &grid)
        case .victory:
            big(Wording.victory, top: 4, color: theme.spark, into: &grid)
        case .playing, .dying:
            if game.timeLeft <= Game.hurryTicks, game.tick % 30 < 20 {
                center(Wording.hurryUp, row: 0, color: theme.danger, into: &grid)
            }
        }
    }

    /// 大きな文字を窓の真ん中に塗る（点は空白のセルの背景色。1 点＝2 桁）。
    private func big(_ text: String, top: Int, color: Rgb, into grid: inout Grid) {
        let left = (brush.layout.fieldWidth - BigFont.span(text) * 2) / 2
        for (row, cells) in BigFont.pixels(text).enumerated() {
            for (offset, lit) in cells.enumerated() where lit {
                brush.paint(
                    FieldArea(column: left + offset * 2, row: top + row, width: 2, height: 1), color: color, into: &grid
                )
            }
        }
    }

    /// 倒した場所に `+100` などを 30 刻み浮かべる（10 刻みに 1 行上がる）。塗ったセルの上には書かない（FR-07）。
    private func popups(_ effects: Effects, camera: Camera, into grid: inout Grid) {
        for popup in effects.popups {
            let rise = (effects.clock - popup.born) / 10
            let row = camera.row(popup.point.y) - rise
            let start = camera.column(popup.point.x)
            for (offset, character) in ("+" + popup.text).enumerated() {
                let column = start + offset
                guard (0..<brush.layout.fieldWidth).contains(column), (0..<brush.layout.fieldHeight).contains(row),
                    brush.cell(grid, column: column, row: row).background == theme.ground
                else {
                    continue
                }
                brush.write(
                    String(character), at: (column, row),
                    colors: CellColors(foreground: theme.spark, background: theme.ground), into: &grid)
            }
        }
    }

    private static func line(_ rank: Int, _ table: HighScoreTable) -> String {
        guard rank < table.entries.count else {
            return String(rank + 1) + "  -------  ----------  --  ------"
        }
        let entry = table.entries[rank]
        let pilot = String(entry.pilot.prefix(10))
        return String(rank + 1) + "  " + Wording.digits(entry.score, 7) + "  " + pilot
            + String(repeating: " ", count: 10 - pilot.count) + "  " + Wording.digits(entry.stage, 2) + "  "
            + Wording.difficulty(entry.difficulty)
    }

    private func center(_ text: String, row: Int, color: Rgb, into grid: inout Grid) {
        let clipped = String(text.prefix(brush.layout.fieldWidth))
        brush.write(
            clipped, at: ((brush.layout.fieldWidth - clipped.count) / 2, row),
            colors: CellColors(foreground: color, background: theme.ground), into: &grid)
    }
}

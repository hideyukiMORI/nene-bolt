import NeNeBoltCore

/// 面の窓に、地形・据え付け・拾うもの・敵・ボス・弾・自機を塗る（FR-07: どれも空白のセルの背景色だけで描き、文字を書かない）。
///
/// 体の大きさは偶数桁にそろえる（1 セル＝2 桁）。体の縦は足もとの行から上へ数え、跳んでいる途中でも行数が変わらない。
struct StagePainter {
    let theme: Theme
    let camera: Camera

    /// 消える足場が消える前に点滅する刻みの数。
    static let warningTicks = 15

    /// 面の窓を地の色で消す。
    static func clear(theme: Theme, into grid: inout Grid) {
        FieldBrush.paint(
            FieldArea(column: 0, row: 0, width: ScreenLayout.fieldWidth, height: ScreenLayout.fieldHeight),
            color: theme.ground,
            into: &grid)
    }

    /// ゲームを 1 枚描く。
    func draw(_ game: Game, into grid: inout Grid) {
        terrain(game, into: &grid)
        markers(game, into: &grid)
        for platform in game.platforms {
            body(platform.box, span: (6, 1), color: theme.fixture, into: &grid)
        }
        for pickup in game.pickups where !pickup.taken {
            body(pickup.box, span: (2, 1), color: color(of: pickup.kind), into: &grid)
        }
        for enemy in game.enemies {
            self.enemy(enemy, tick: game.tick, into: &grid)
        }
        if case .fighting(let boss) = game.boss {
            let flashing = boss.invulnerable > 0 && boss.invulnerable % 4 < 2
            body(boss.box, span: (4, 3), color: flashing ? theme.spark : theme.boss, into: &grid)
        }
        for shot in game.shots {
            let color = shot.owner == .runner ? (shot.charged ? theme.spark : theme.runnerShot) : theme.danger
            body(shot.box, span: (shot.charged ? 4 : 2, 1), color: color, into: &grid)
        }
        runner(game, into: &grid)
    }

    private func terrain(_ game: Game, into grid: inout Grid) {
        let (columns, rows) = camera.visibleCells
        for row in rows {
            for column in columns {
                guard
                    let color = color(of: game.terrain(column: column, row: row), game: game, column: column, row: row)
                else {
                    continue
                }
                cell(column: column, row: row, color: color, into: &grid)
            }
        }
    }

    /// 地形のセルの色。空きなら nil。
    private func color(of terrain: Terrain, game: Game, column: Int, row: Int) -> Rgb? {
        switch terrain {
        case .empty:
            return nil
        case .solid:
            return theme.rock
        case .ice:
            return Rgb.mix(theme.rock, theme.accent, percent: 50)
        case .ladder:
            return row % 2 == 0 ? theme.fixture : Rgb.mix(theme.fixture, theme.ground, percent: 55)
        case .spike:
            return theme.danger
        case .vanishing(let group):
            return vanishing(group: group, at: game.stageTick)
        case .conveyor(let heading):
            let stripe = (column + heading.sign * game.stageTick / 4) % 2 == 0
            return stripe ? theme.rock : Rgb.mix(theme.rock, theme.text, percent: 20)
        }
    }

    /// 消える足場の色。見えている間は据え付けの色で、消える前に点滅し、消えている間はうっすら跡を残す（覚えて渡るもの）。
    private func vanishing(group: Int, at tick: Int) -> Rgb {
        guard VanishingClock.isVisible(group: group, at: tick) else {
            return Rgb.mix(theme.ground, theme.fixture, percent: 18)
        }
        let goesSoon = !VanishingClock.isVisible(group: group, at: tick + StagePainter.warningTicks)
        if goesSoon, tick % 4 < 2 {
            return Rgb.mix(theme.fixture, theme.ground, percent: 50)
        }
        return Rgb.mix(theme.fixture, theme.text, percent: 30)
    }

    /// 中間地点・ゴールの旗・ボスの部屋の扉。
    private func markers(_ game: Game, into grid: inout Grid) {
        for spawn in game.map.spawns {
            switch spawn.kind {
            case .checkpoint:
                let reached = game.checkpoint == spawn
                cell(column: spawn.column, row: spawn.row, color: reached ? theme.accent : theme.dim, into: &grid)
            case .goal:
                cell(column: spawn.column, row: spawn.row, color: theme.accentAlt, into: &grid)
                cell(column: spawn.column, row: spawn.row - 1, color: theme.accentAlt, into: &grid)
                cell(column: spawn.column, row: spawn.row - 2, color: theme.text, into: &grid)
            case .door:
                if !game.doorClosed {
                    cell(column: spawn.column, row: spawn.row, color: theme.frame, into: &grid)
                }
            case .start, .walker, .hopper, .flyer, .turret, .splitter, .coin, .health, .oneUp, .powerUp,
                .mover, .boss:
                continue
            }
        }
    }

    private func enemy(_ enemy: Enemy, tick: Int, into grid: inout Grid) {
        switch enemy.state {
        case .dormant, .active:
            body(enemy.box, span: (2, 1), color: theme.color(of: enemy.kind), into: &grid)
        case .dying(let ticksLeft):
            if ticksLeft % 2 == 0 || tick % 2 == 0 {
                body(enemy.box, span: (2, 1), color: theme.spark, into: &grid)
            }
        }
    }

    /// 自機。2 桁 × 2 行で、向いている側の上の桁を目の色にする。無敵の間と倒れている間は点滅する。
    private func runner(_ game: Game, into grid: inout Grid) {
        let runner = game.runner
        if case .dying = game.phase {
            if game.tick % 4 < 2 {
                body(runner.box, span: (2, 2), color: theme.spark, into: &grid)
            }
            return
        }
        if runner.invulnerable > 0, runner.invulnerable % 6 < 3 {
            return
        }
        let color = runner.isCharged ? Rgb.mix(theme.runner, theme.spark, percent: 60) : theme.runner
        let (column, row) = body(runner.box, span: (2, 2), color: color, into: &grid)
        let eye = runner.facing == .right ? column + 1 : column
        FieldBrush.paint(
            FieldArea(column: eye, row: row, width: 1, height: 1), color: theme.text, into: &grid)
    }

    /// 地形のセル 1 つ（2 桁 × 1 行）。
    private func cell(column: Int, row: Int, color: Rgb, into grid: inout Grid) {
        FieldBrush.paint(
            FieldArea(
                column: camera.column(Field.units(column)), row: camera.row(Field.units(row)), width: 2, height: 1),
            color: color, into: &grid)
    }

    /// 体を `columns` 桁 × `rows` 行で塗る。横は箱の真ん中にそろえ、縦は足もとの行から上へ数える。塗った左上を返す。
    @discardableResult
    private func body(_ box: Box, span: (columns: Int, rows: Int), color: Rgb, into grid: inout Grid) -> (Int, Int) {
        let (columns, rows) = span
        let column = camera.column(box.centerX) - columns / 2
        let row = camera.row(box.bottom - 1) - rows + 1
        FieldBrush.paint(
            FieldArea(column: column, row: row, width: columns, height: rows), color: color, into: &grid)
        return (column, row)
    }

    private func color(of kind: PickupKind) -> Rgb {
        switch kind {
        case .coin: theme.pickup
        case .health: theme.runner
        case .oneUp: theme.accentAlt
        case .powerUp: theme.spark
        }
    }
}

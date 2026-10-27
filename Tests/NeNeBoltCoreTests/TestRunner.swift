@testable import NeNeBoltCore

/// テストの中だけのランナー（本物のランナーの AI は Engine に Phase 3-4 で入る）。どれも Core の公開の状態だけを読む。
enum TestRunner: CaseIterable {
    /// 乱数でボタンを押す（しばらく同じ組を押し続ける）。
    case random
    /// 右へ走り、前が壁か穴か敵なら跳び、撃ち続け、梯子があれば上る。
    case forward

    func buttons(for game: Game, memory: inout Int, using generator: inout some RandomNumberGenerator) -> Buttons {
        switch self {
        case .random:
            if memory <= 0 || game.tick % 20 == 0 {
                memory = Int(UInt8.random(in: 0...63, using: &generator))
            }
            return Buttons(rawValue: UInt8(memory))
        case .forward:
            return TestRunner.forwardButtons(for: game)
        }
    }

    private static func forwardButtons(for game: Game) -> Buttons {
        let runner = game.runner
        var buttons: Buttons = [.right]
        if game.tick % 6 < 3 {
            buttons.insert(.fire)
        }
        if case .climbing = runner.posture {
            return [.up]
        }
        if game.ladderColumn(for: runner.box) != nil, game.tick % 240 < 120 {
            buttons.insert(.up)
        }
        let box = runner.box
        let aheadColumn = Field.cell(box.right + 8)
        let footRow = Field.cell(box.bottom - 1)
        let wall = game.isSolid(game.terrain(column: aheadColumn, row: footRow))
        let gap = !game.isSolid(game.terrain(column: aheadColumn, row: footRow + 1))
        let enemy = game.enemies.contains {
            $0.isSolid && $0.box.origin.x > box.origin.x && $0.box.origin.x - box.right < 40
        }
        if case .standing = runner.posture, wall || gap || enemy {
            buttons.insert(.jump)
        } else if case .airborne = runner.posture, runner.velocity.dy < 0 {
            buttons.insert(.jump)
        }
        return buttons
    }
}

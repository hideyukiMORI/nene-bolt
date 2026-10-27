import NeNeBoltCore

/// 仮のランナー（Phase 3-2・ADR 0007）。右へ走り、前が壁か穴か敵なら跳び、撃ち、梯子があれば上る。
/// ときどき迷って立ち止まる。本物のランナーとキャストは Phase 3-4 で入る。
///
/// Core の公開の状態を読み、押すボタンの組だけを返す（ARC-004）。人が押すのと同じ型で、同じ経路で Core に渡る。
public struct Autopilot: Sendable {
    /// 迷って立ち止まっている残りの刻み。
    private var pause = 0

    /// 新しいゲームのランナー。
    public init() {}

    /// この刻みに押すボタン。
    public mutating func buttons(for game: Game, using generator: inout some RandomNumberGenerator) -> Buttons {
        let runner = game.runner
        if pause > 0 {
            pause -= 1
            return game.tick % 8 < 4 ? [.fire] : []
        }
        if case .standing = runner.posture, UInt16.random(in: 0..<1_000, using: &generator) < 4 {
            pause = Int.random(in: 10...40, using: &generator)
        }
        if case .climbing = runner.posture {
            return [.up]
        }
        var buttons: Buttons = [.right]
        if game.tick % 6 < 3 {
            buttons.insert(.fire)
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
        switch runner.posture {
        case .standing:
            if wall || gap || enemy {
                buttons.insert(.jump)
            }
        case .airborne:
            if runner.velocity.dy < 0 {
                buttons.insert(.jump)
            }
        case .climbing:
            break
        }
        return buttons
    }
}

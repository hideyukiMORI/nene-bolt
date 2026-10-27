/// 中間地点・ゴール・ボスの部屋（FR-02a・FR-02c）。
extension Game {
    /// ゴールに着いたときの残り時間のボーナス（残り 1 秒＝30 刻みにつき）。
    static let timeBonusPerSecond = 10

    mutating func checkProgress(tuning: Tuning, events: inout [GameEvent]) {
        let center = runner.box.centerX
        if case .start = checkpoint.kind, let mark = map.first(.checkpoint), center >= mark.origin.x {
            checkpoint = mark
            events.append(.checkpointReached)
        }
        if let goal = map.first(.goal), center >= goal.origin.x {
            let bonus = timeLeft / 30 * Game.timeBonusPerSecond
            score += bonus
            events.append(.stageCleared(stage))
            events.append(.timeBonus(points: bonus))
            phase = .cleared(ticksLeft: Game.clearedTicks)
            shots = []
            return
        }
        if case .waiting = boss, let door = map.first(.door), let lair = map.first(.boss),
            runner.position.x > door.origin.x + Field.cellUnits
        {
            doorClosed = true
            let origin = Point(x: lair.origin.x, y: lair.origin.y + Field.cellUnits - Boss.height)
            boss = .fighting(Boss(at: origin, health: tuning.bossHealth))
            events.append(.bossAppeared)
        }
    }

    /// ボスを倒した。
    mutating func defeatBoss(events: inout [GameEvent]) {
        score += Game.bossPoints
        events.append(.bossDefeated(points: Game.bossPoints))
        boss = .defeated
        shots = []
        phase = .victory(ticksLeft: Game.victoryTicks)
    }
}

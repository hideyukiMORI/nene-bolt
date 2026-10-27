/// 1 刻みの順番（ADR 0005）。順番はこの 1 か所だけで決める。
extension Game {
    /// 制限時間がこれだけ残ったら急かす（30 秒）。
    static let hurryTicks = 900

    mutating func advance(
        _ buttons: Buttons, tuning: Tuning, using generator: inout some RandomNumberGenerator, events: inout [GameEvent]
    ) {
        tick += 1
        switch phase {
        case .intro(let ticksLeft):
            phase = ticksLeft > 1 ? .intro(ticksLeft: ticksLeft - 1) : .playing
        case .playing:
            play(buttons, tuning: tuning, using: &generator, events: &events)
        case .dying(let ticksLeft):
            if ticksLeft > 1 {
                phase = .dying(ticksLeft: ticksLeft - 1)
            } else {
                revive(events: &events)
            }
        case .cleared(let ticksLeft):
            if ticksLeft > 1 {
                phase = .cleared(ticksLeft: ticksLeft - 1)
            } else if let next = stage.next {
                load(next, events: &events)
            } else {
                end(.cleared, events: &events)
            }
        case .victory(let ticksLeft):
            if ticksLeft > 1 {
                phase = .victory(ticksLeft: ticksLeft - 1)
            } else {
                end(.cleared, events: &events)
            }
        }
        runner.held = buttons
        if case .running = status, tick >= Game.tickLimit {
            end(.timeLimit, events: &events)
        }
    }

    /// 遊んでいる刻み。時計 → 動く足場 → 自機の操作と動き → 地形の危険 → 自機の弾 → 敵 → 敵の弾 → 体当たり → 拾うもの → ゴールと中間地点とボスの部屋 → ボス。
    /// 途中で 1 機失ったら、その刻みの残りは進めない。
    private mutating func play(
        _ buttons: Buttons, tuning: Tuning, using generator: inout some RandomNumberGenerator, events: inout [GameEvent]
    ) {
        countDown(events: &events)
        movePlatforms()
        control(buttons, events: &events)
        moveRunner()
        checkHazards(events: &events)
        guard case .playing = phase else {
            return
        }
        advanceRunnerShots(events: &events)
        moveEnemies(tuning: tuning, using: &generator)
        advanceEnemyShots(events: &events)
        resolveContacts(tuning: tuning, events: &events)
        guard case .playing = phase else {
            return
        }
        collectPickups(events: &events)
        checkProgress(tuning: tuning, events: &events)
        runBoss(tuning: tuning, using: &generator, events: &events)
        finishExplosions()
        if runner.invulnerable > 0 {
            runner.invulnerable -= 1
        }
    }

    private mutating func countDown(events: inout [GameEvent]) {
        stageTick += 1
        timeLeft -= 1
        if timeLeft == Game.hurryTicks {
            events.append(.hurryUp)
        }
        if timeLeft <= 0 {
            loseLife(.timeUp, events: &events)
        }
    }
}

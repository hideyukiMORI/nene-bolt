/// ボスの動き（FR-02c・ADR 0005）。間を置いて、跳ぶ・扇に撃つ・突進・光って撃つ、を乱数で選ぶ。
extension Game {
    /// 光っている刻みの数。
    static let flashTicks = 24

    mutating func runBoss(tuning: Tuning, using generator: inout some RandomNumberGenerator, events: inout [GameEvent])
    {
        guard case .playing = phase, case .fighting(var current) = boss else {
            return
        }
        if current.invulnerable > 0 {
            current.invulnerable -= 1
        }
        current.facing = runner.box.centerX < current.box.centerX ? .left : .right
        switch current.attack {
        case .idle(let ticksLeft):
            current = wait(current, ticksLeft: ticksLeft, using: &generator)
        case .leap:
            current = settle(current)
            if current.velocity.dy == 0, isSupported(current.box) {
                current.attack = .idle(ticksLeft: tuning.bossPause)
            }
        case .barrage:
            fan(from: current, count: 3, tuning: tuning)
            current.attack = .idle(ticksLeft: tuning.bossPause)
        case .dash:
            current = dash(current, tuning: tuning)
        case .flash(let ticksLeft):
            current = glow(current, ticksLeft: ticksLeft, tuning: tuning, events: &events)
        }
        boss = .fighting(current)
    }

    /// 間を数え、尽きたら次の攻撃を選ぶ。跳ぶなら跳び始める。
    private func wait(_ boss: Boss, ticksLeft: Int, using generator: inout some RandomNumberGenerator) -> Boss {
        var next = boss
        next.attack = ticksLeft > 1 ? .idle(ticksLeft: ticksLeft - 1) : Game.choose(using: &generator)
        next = settle(next)
        if case .leap = next.attack {
            next.velocity = Velocity(dx: next.facing.sign * 3, dy: -12)
        }
        return next
    }

    /// 光る。光り始めに出来事を出し、光り終わると 5 発を扇に撃つ。
    private mutating func glow(_ boss: Boss, ticksLeft: Int, tuning: Tuning, events: inout [GameEvent]) -> Boss {
        var next = boss
        if ticksLeft == Game.flashTicks {
            events.append(.bossFlash)
        }
        if ticksLeft > 1 {
            next.attack = .flash(ticksLeft: ticksLeft - 1)
        } else {
            fan(from: boss, count: 5, tuning: tuning)
            next.attack = .idle(ticksLeft: tuning.bossPause)
        }
        return next
    }

    private static func choose(using generator: inout some RandomNumberGenerator) -> BossAttack {
        let pick = Int.random(in: 0..<4, using: &generator)
        if pick == 0 {
            return .leap
        }
        if pick == 1 {
            return .barrage
        }
        return pick == 2 ? .dash : .flash(ticksLeft: flashTicks)
    }

    /// 重力と横の速さで動かす（床と壁で止める）。
    private func settle(_ boss: Boss) -> Boss {
        var next = boss
        let dy = min(Runner.maxFall, boss.velocity.dy + Runner.gravity)
        let across = slide(boss.box, dx: boss.velocity.dx, dy: 0, carriesOntoPlatforms: false)
        let down = slide(across.box, dx: 0, dy: dy, carriesOntoPlatforms: false)
        next.position = down.box.origin
        next.velocity = Velocity(dx: down.blocked ? 0 : boss.velocity.dx, dy: down.blocked ? 0 : dy)
        return next
    }

    private func dash(_ boss: Boss, tuning: Tuning) -> Boss {
        var next = boss
        let run = slide(boss.box, dx: boss.facing.sign * 6, dy: 0, carriesOntoPlatforms: false)
        next.position = run.box.origin
        if run.blocked {
            next.attack = .idle(ticksLeft: tuning.bossPause)
        }
        return settle(next)
    }

    /// 自機の方へ扇に撃つ。
    private mutating func fan(from boss: Boss, count: Int, tuning: Tuning) {
        let origin = Point(x: boss.box.centerX - 4, y: boss.box.origin.y + 12)
        for index in 0..<count {
            let spread = index - count / 2
            shots.append(
                Shot(
                    owner: .enemy, position: origin,
                    velocity: Velocity(dx: boss.facing.sign * tuning.enemyShotSpeed, dy: spread * 2),
                    width: 8, height: 8, damage: tuning.contactDamage + 1, charged: false, life: 90))
        }
    }
}

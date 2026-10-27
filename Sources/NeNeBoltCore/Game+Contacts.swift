/// 自機と敵・ボスの体当たり（FR-02・FR-02d）。上から落ちてきて踏めば敵が倒れ、それ以外は自機が被弾する。
extension Game {
    /// 踏んだと数える、敵の上端からの深さ（単位）。
    static let stompDepth = 6

    mutating func resolveContacts(tuning: Tuning, events: inout [GameEvent]) {
        for index in enemies.indices {
            let enemy = enemies[index]
            guard enemy.isSolid, enemy.box.overlaps(runner.box) else {
                continue
            }
            if isStomp(on: enemy) {
                damage(at: index, by: enemy.health, method: .stomp, events: &events)
                runner.velocity = Velocity(dx: runner.velocity.dx, dy: -Runner.stompBounce)
                runner.posture = .airborne
            } else {
                hurt(by: tuning.contactDamage, events: &events)
            }
            guard case .playing = phase else {
                return
            }
        }
        if case .fighting(let current) = boss, current.box.overlaps(runner.box) {
            hurt(by: Boss.contactDamage, events: &events)
        }
    }

    /// 落ちてきていて、前の刻みの足が敵の上端あたりより上にあったか。
    private func isStomp(on enemy: Enemy) -> Bool {
        guard enemy.kind.isStompable, runner.velocity.dy > 0 else {
            return false
        }
        return runner.box.bottom - runner.velocity.dy <= enemy.box.origin.y + Game.stompDepth
    }

    /// 自機が被弾する。無敵の間は何も起きない。パワーアップは 1 段戻り、体力が尽きたら 1 機失う。
    mutating func hurt(by amount: Int, events: inout [GameEvent]) {
        guard runner.invulnerable == 0, case .playing = phase else {
            return
        }
        runner.health = max(0, runner.health - amount)
        runner.power = max(0, runner.power - 1)
        runner.invulnerable = Runner.invulnerableTicks
        runner.velocity = Velocity(dx: -runner.facing.sign * 2, dy: -4)
        if case .climbing = runner.posture {
            runner.posture = .airborne
        }
        events.append(.runnerHit(damage: amount))
        if runner.health == 0 {
            loseLife(.health, events: &events)
        }
    }

    /// 重なっている拾うものを拾う。
    mutating func collectPickups(events: inout [GameEvent]) {
        for index in pickups.indices where !pickups[index].taken && pickups[index].box.overlaps(runner.box) {
            pickups[index].taken = true
            let kind = pickups[index].kind
            score += kind.points
            events.append(.pickedUp(kind))
            apply(kind, events: &events)
        }
    }

    private mutating func apply(_ kind: PickupKind, events: inout [GameEvent]) {
        switch kind {
        case .coin:
            coins += 1
            if coins >= Game.coinsPerLife {
                coins = 0
                reserve += 1
                events.append(.coinsOneUp)
            }
        case .health:
            runner.health = min(Runner.maxHealth, runner.health + 4)
        case .oneUp:
            reserve += 1
        case .powerUp:
            runner.power = min(Runner.maxPower, runner.power + 1)
        }
    }
}

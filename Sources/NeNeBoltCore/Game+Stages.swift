/// 面の始まり・やり直し・終わり（FR-02a・FR-02d・FR-03）。
extension Game {
    /// 面を読み込んで始める。
    mutating func load(_ next: Stage, events: inout [GameEvent]) {
        stage = next
        map = StageCatalog.map(of: next)
        checkpoint = map.first(.start) ?? checkpoint
        pickups = map.spawns.compactMap(Game.pickup)
        restart()
        phase = .intro(ticksLeft: Game.introTicks)
        events.append(.stageStarted(next))
    }

    /// いまの挑戦をやり直す（自機・敵・弾・動く足場・ボス・扉・時計を元に戻す。拾ったものとコインは戻さない）。
    mutating func restart() {
        runner = Runner.standing(on: checkpoint)
        nextEnemyID = 0
        enemies = []
        for spawn in map.spawns {
            if let kind = Game.enemyKind(of: spawn.kind) {
                enemies.append(Enemy(id: nextEnemyID, kind: kind, position: Game.enemyOrigin(spawn, kind)))
                nextEnemyID += 1
            }
        }
        shots = []
        platforms = map.spawns.filter { $0.kind == .mover }.map(Game.platform)
        boss = .waiting
        doorClosed = false
        stageTick = 0
        timeLeft = Game.stageTime
    }

    /// 1 機失う。死んでいる間の帯を出し、終わったら `revive` が続きを決める。
    mutating func loseLife(_ cause: LossCause, events: inout [GameEvent]) {
        guard case .playing = phase else {
            return
        }
        events.append(.lifeLost(cause))
        phase = .dying(ticksLeft: Game.dyingTicks)
        shots = []
    }

    /// 死んでいる間が終わった。残機があればやり直し、無ければ終わる。
    mutating func revive(events: inout [GameEvent]) {
        guard reserve > 0 else {
            end(.outOfLives, events: &events)
            return
        }
        reserve -= 1
        restart()
        phase = .playing
        events.append(.respawned)
    }

    /// ゲームを終える。終わり方は最初の 1 つだけ。
    mutating func end(_ ending: GameEnding, events: inout [GameEvent]) {
        guard case .running = status else {
            return
        }
        status = .over(ending)
        events.append(.gameOver(ending))
    }

    static func enemyKind(of kind: SpawnKind) -> EnemyKind? {
        switch kind {
        case .walker: .walker
        case .hopper: .hopper
        case .flyer: .flyer
        case .turret: .turret
        case .splitter: .splitter
        case .start, .checkpoint, .goal, .boss, .door, .coin, .health, .oneUp, .powerUp, .mover: nil
        }
    }

    /// 敵をそのセルの下端に立たせる位置。
    static func enemyOrigin(_ spawn: Spawn, _ kind: EnemyKind) -> Point {
        Point(
            x: spawn.origin.x + (Field.cellUnits - kind.size.width) / 2,
            y: spawn.origin.y + Field.cellUnits - kind.size.height)
    }

    static func pickup(_ spawn: Spawn) -> Pickup? {
        let kind: PickupKind
        switch spawn.kind {
        case .coin: kind = .coin
        case .health: kind = .health
        case .oneUp: kind = .oneUp
        case .powerUp: kind = .powerUp
        case .start, .checkpoint, .goal, .boss, .door, .walker, .hopper, .flyer, .turret, .splitter, .mover: return nil
        }
        let offset = (Field.cellUnits - Pickup.size) / 2
        return Pickup(kind: kind, position: Point(x: spawn.origin.x + offset, y: spawn.origin.y + offset), taken: false)
    }

    static func platform(_ spawn: Spawn) -> Platform {
        let reach = Field.units(Platform.reach)
        return Platform(position: spawn.origin, step: 1, minX: spawn.origin.x - reach, maxX: spawn.origin.x + reach)
    }
}

/// 弾の進み方と当たり方（FR-02）。弾も `substep` 以下に刻んで当たりを見る（敵の欠片より速い弾でも飛び越えない）。
extension Game {
    mutating func advanceRunnerShots(events: inout [GameEvent]) {
        var survivors: [Shot] = []
        for shot in shots {
            switch shot.owner {
            case .runner:
                if let flown = flyRunnerShot(shot, events: &events) {
                    survivors.append(flown)
                }
            case .enemy:
                survivors.append(shot)
            }
        }
        shots = survivors
    }

    /// 自機の弾を 1 刻み進める。地形・敵・ボスに当たるか、寿命が尽きたら nil。溜め撃ちは敵を倒しても進む。
    private mutating func flyRunnerShot(_ shot: Shot, events: inout [GameEvent]) -> Shot? {
        var current = shot
        current.life -= 1
        for point in Game.path(from: shot.position, by: shot.velocity) {
            current.position = point
            if collides(current.box, before: current.box, movingDown: false) {
                return nil
            }
            if strikeBoss(current, events: &events) {
                return nil
            }
            if let index = enemies.firstIndex(where: { $0.isSolid && $0.box.overlaps(current.box) }) {
                let survived = damage(at: index, by: current.damage, method: .shot, events: &events)
                if survived || !current.charged {
                    return nil
                }
            }
        }
        return current.life > 0 ? current : nil
    }

    /// 1 刻みの移動を `substep` 以下に刻んだ途中の位置（最後が行き先）。
    static func path(from start: Point, by velocity: Velocity) -> [Point] {
        let pieces = max(1, (max(abs(velocity.dx), abs(velocity.dy)) + substep - 1) / substep)
        return (1...pieces).map { piece in
            Point(x: start.x + velocity.dx * piece / pieces, y: start.y + velocity.dy * piece / pieces)
        }
    }

    mutating func advanceEnemyShots(events: inout [GameEvent]) {
        var survivors: [Shot] = []
        for shot in shots {
            guard case .enemy = shot.owner else {
                survivors.append(shot)
                continue
            }
            var current = shot
            current.life -= 1
            var spent = current.life <= 0
            for point in Game.path(from: shot.position, by: shot.velocity) where !spent {
                current.position = point
                if current.box.overlaps(runner.box) {
                    hurt(by: current.damage, events: &events)
                    spent = true
                } else if collides(current.box, before: current.box, movingDown: false) {
                    spent = true
                }
            }
            if !spent {
                survivors.append(current)
            }
        }
        shots = survivors
    }

    /// 自機の弾がボスに当たるか。当たったら体力を減らす。
    private mutating func strikeBoss(_ shot: Shot, events: inout [GameEvent]) -> Bool {
        guard case .fighting(var current) = boss, current.box.overlaps(shot.box) else {
            return false
        }
        if current.invulnerable == 0 {
            current.health = max(0, current.health - shot.damage)
            current.invulnerable = Boss.invulnerableTicks
            events.append(.bossHit(healthLeft: current.health))
        }
        boss = .fighting(current)
        if current.health == 0 {
            defeatBoss(events: &events)
        }
        return true
    }

    /// 敵を撃つ。生き残ったら true。倒したら得点を足し、分かれる敵は欠片を 2 つ出す。
    @discardableResult
    mutating func damage(at index: Int, by amount: Int, method: DefeatMethod, events: inout [GameEvent]) -> Bool {
        var enemy = enemies[index]
        enemy.health -= amount
        guard enemy.health <= 0 else {
            enemies[index] = enemy
            events.append(.enemyHit(at: enemy.position))
            return true
        }
        enemy.state = .dying(ticksLeft: Game.explosionTicks)
        enemies[index] = enemy
        score += enemy.kind.points
        events.append(.enemyDefeated(enemy.kind, points: enemy.kind.points, at: enemy.position, by: method))
        if case .splitter = enemy.kind {
            split(enemy)
        }
        return false
    }

    private mutating func split(_ enemy: Enemy) {
        for heading in [Heading.left, .right] {
            var shard = Enemy(
                id: nextEnemyID, kind: .shard,
                position: Point(
                    x: enemy.box.centerX - EnemyKind.shard.size.width / 2,
                    y: enemy.box.bottom - EnemyKind.shard.size.height))
            nextEnemyID += 1
            shard.facing = heading
            shard.state = .active
            shard.velocity = Velocity(dx: 0, dy: -6)
            enemies.append(shard)
        }
    }
}

/// 敵の動き（FR-02f）。
extension Game {
    /// 自機がこれより近づくと動き出す（セル）。
    static let activationCells = 20
    /// 砲台が撃つ距離（セル）。
    static let turretRange = 14

    mutating func moveEnemies(tuning: Tuning, using generator: inout some RandomNumberGenerator) {
        for index in enemies.indices {
            var enemy = enemies[index]
            if case .dormant = enemy.state,
                abs(enemy.position.x - runner.position.x) < Field.units(Game.activationCells)
            {
                enemy.state = .active
            }
            guard case .active = enemy.state else {
                enemies[index] = enemy
                continue
            }
            enemy.timer += 1
            enemy = behave(enemy, tuning: tuning, using: &generator)
            enemies[index] = enemy
        }
        enemies.removeAll { $0.position.y > map.height }
    }

    private mutating func behave(
        _ enemy: Enemy, tuning: Tuning, using generator: inout some RandomNumberGenerator
    ) -> Enemy {
        switch enemy.kind {
        case .walker, .splitter: return walk(enemy, speed: tuning.enemySpeed)
        case .shard: return walk(enemy, speed: 2)
        case .hopper: return hop(enemy, tuning: tuning, using: &generator)
        case .flyer: return fly(enemy, tuning: tuning)
        case .turret: return aim(enemy, tuning: tuning)
        }
    }

    /// 歩く: 向きへ進み、壁にぶつかるか足の先が崖なら向きを変える。重力で落ちる。
    private func walk(_ enemy: Enemy, speed: Int) -> Enemy {
        var next = enemy
        let ahead = slide(enemy.box, dx: enemy.facing.sign * speed, dy: 0, carriesOntoPlatforms: false)
        let toe = enemy.facing.sign > 0 ? ahead.box.right : ahead.box.origin.x - 1
        let grounded = isSupported(enemy.box)
        let cliff = grounded && !isSolid(terrain(column: Field.cell(toe), row: Field.cell(enemy.box.bottom)))
        if ahead.blocked || cliff {
            next.facing = enemy.facing.reversed
        } else {
            next.position = ahead.box.origin
        }
        return fall(next)
    }

    /// 重力で落とす（床で止める）。
    private func fall(_ enemy: Enemy) -> Enemy {
        var next = enemy
        let dy = min(Runner.maxFall, enemy.velocity.dy + Runner.gravity)
        let dropped = slide(next.box, dx: 0, dy: dy, carriesOntoPlatforms: true)
        next.position = dropped.box.origin
        next.velocity = Velocity(dx: enemy.velocity.dx, dy: dropped.blocked ? 0 : dy)
        return next
    }

    /// 跳ねる: 床にいて間隔が来たら、自機の方へ跳ぶ（間隔は少し乱れる）。
    private func hop(_ enemy: Enemy, tuning: Tuning, using generator: inout some RandomNumberGenerator) -> Enemy {
        var next = enemy
        if isSupported(enemy.box), enemy.timer >= tuning.hopInterval {
            next.timer = -Int.random(in: 0..<10, using: &generator)
            next.facing = runner.box.centerX < enemy.box.centerX ? .left : .right
            next.velocity = Velocity(dx: next.facing.sign * 2, dy: -9)
        }
        if !isSupported(next.box) || next.velocity.dy < 0 {
            let across = slide(next.box, dx: next.velocity.dx, dy: 0, carriesOntoPlatforms: false)
            next.position = across.box.origin
        }
        next = fall(next)
        if isSupported(next.box) {
            next.velocity = Velocity(dx: 0, dy: next.velocity.dy)
        }
        return next
    }

    /// 飛ぶ敵の横の速さの上限（自機の走る速さより 1 遅い）。
    static let flyerTopSpeed = Runner.runSpeed - 1

    /// 飛ぶ: 自機の方へ寄りながら上下に波打つ（地形を気にしない）。
    private func fly(_ enemy: Enemy, tuning: Tuning) -> Enemy {
        var next = enemy
        next.facing = runner.box.centerX < enemy.box.centerX ? .left : .right
        let wave = (enemy.timer / 12) % 2 == 0 ? 1 : -1
        let toward = runner.box.centerY < enemy.box.centerY ? -1 : 1
        let dy = enemy.timer % 3 == 0 ? toward : wave
        // 横は自機より遅くする（同じ速さだと振り切れず、触れ続けて体力が尽きる・ADR 0008）
        let speed = min(tuning.enemySpeed, Game.flyerTopSpeed)
        next.position = enemy.position.moved(by: Velocity(dx: next.facing.sign * speed, dy: dy))
        return next
    }

    /// 砲台: 自機が近ければ、間隔ごとに自機の方へ横に撃つ。
    private mutating func aim(_ enemy: Enemy, tuning: Tuning) -> Enemy {
        var next = enemy
        next.facing = runner.box.centerX < enemy.box.centerX ? .left : .right
        let near = abs(runner.box.centerX - enemy.box.centerX) < Field.units(Game.turretRange)
        if near, enemy.timer % tuning.turretInterval == 0 {
            let origin = Point(x: enemy.box.centerX - 3, y: enemy.box.origin.y + 4)
            shots.append(
                Shot(
                    owner: .enemy, position: origin,
                    velocity: Velocity(dx: next.facing.sign * tuning.enemyShotSpeed, dy: 0),
                    width: 6, height: 6, damage: tuning.contactDamage, charged: false, life: 90))
        }
        return fall(next)
    }

    /// 爆発を 1 刻み進め、終わった敵を消す。
    mutating func finishExplosions() {
        for index in enemies.indices {
            if case .dying(let ticksLeft) = enemies[index].state {
                enemies[index].state = .dying(ticksLeft: ticksLeft - 1)
            }
        }
        enemies.removeAll { enemy in
            if case .dying(let ticksLeft) = enemy.state {
                return ticksLeft <= 0
            }
            return false
        }
    }
}

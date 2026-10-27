/// 動き（ADR 0005）。動く物はどれも、1 刻みの移動を `substep` 以下に刻み、刻むたびに地形との当たりを見る。
/// だから速く落ちても床を突き抜けない（REQUIREMENTS 第 3 節）。
extension Game {
    /// 移動を刻む最大の量（単位）。どの地形のセルよりも、どの体よりも小さい。
    static let substep = 4

    /// 箱を横か縦に動かす。ぶつかったら手前で止める。
    func slide(_ box: Box, dx: Int, dy: Int, carriesOntoPlatforms: Bool) -> Slide {
        let distance = max(abs(dx), abs(dy))
        guard distance > 0 else {
            return Slide(box: box, blocked: false)
        }
        let pieces = (distance + Game.substep - 1) / Game.substep
        var current = box
        for piece in 1...pieces {
            let candidate = Box(
                origin: Point(x: box.origin.x + dx * piece / pieces, y: box.origin.y + dy * piece / pieces),
                width: box.width, height: box.height)
            if blocks(candidate, before: box, dy: dy, platforms: carriesOntoPlatforms) {
                let contact = flush(from: current, toward: candidate, before: box, platforms: carriesOntoPlatforms)
                return Slide(box: contact, blocked: true)
            }
            current = candidate
        }
        return Slide(box: current, blocked: false)
    }

    private func blocks(_ candidate: Box, before: Box, dy: Int, platforms: Bool) -> Bool {
        let down = dy > 0
        return collides(candidate, before: before, movingDown: down)
            || (platforms && down && landsOnPlatform(candidate, before: before))
    }

    /// ぶつかる手前まで 1 単位ずつ寄せる（壁や床にぴったり付ける）。
    private func flush(from current: Box, toward candidate: Box, before: Box, platforms: Bool) -> Box {
        let stepX = (candidate.origin.x - current.origin.x).signum()
        let stepY = (candidate.origin.y - current.origin.y).signum()
        var box = current
        while box.origin != candidate.origin {
            let next = box.moved(by: Velocity(dx: stepX, dy: stepY))
            if blocks(next, before: before, dy: stepY, platforms: platforms) {
                return box
            }
            box = next
        }
        return box
    }

    /// 上から動く足場に乗るか（前の刻みで足場の上面より上にいた）。
    func landsOnPlatform(_ box: Box, before: Box) -> Bool {
        platforms.contains { $0.box.overlaps(box) && before.bottom <= $0.box.origin.y }
    }

    /// 乗っている動く足場（足のすぐ下）。
    func platform(under box: Box) -> Platform? {
        let feet = Box(origin: Point(x: box.origin.x, y: box.bottom), width: box.width, height: 1)
        return platforms.first { $0.box.overlaps(feet) && $0.box.origin.y == box.bottom }
    }

    mutating func movePlatforms() {
        for index in platforms.indices {
            var lift = platforms[index]
            let carried = platform(under: runner.box).map { $0 == lift } ?? false
            if lift.position.x + lift.step < lift.minX || lift.position.x + lift.step > lift.maxX {
                lift.step = -lift.step
            }
            lift.position = Point(x: lift.position.x + lift.step, y: lift.position.y)
            platforms[index] = lift
            if carried, case .standing = runner.posture {
                let moved = slide(runner.box, dx: lift.step, dy: 0, carriesOntoPlatforms: false)
                runner.position = moved.box.origin
            }
        }
    }

    /// 自機を 1 刻み動かす（重力・コンベア・横・縦の順）。
    mutating func moveRunner() {
        var velocity = runner.velocity
        if case .climbing = runner.posture {
            moveClimber()
            return
        }
        velocity = Velocity(dx: velocity.dx, dy: min(Runner.maxFall, velocity.dy + Runner.gravity))
        var drift = 0
        if case .standing = runner.posture, case .conveyor(let heading) = footing(of: runner.box) {
            drift = heading.sign
        }
        let horizontal = slide(runner.box, dx: velocity.dx + drift, dy: 0, carriesOntoPlatforms: false)
        if horizontal.blocked {
            velocity = Velocity(dx: 0, dy: velocity.dy)
        }
        let vertical = slide(horizontal.box, dx: 0, dy: velocity.dy, carriesOntoPlatforms: true)
        runner.position = vertical.box.origin
        if vertical.blocked {
            runner.posture = velocity.dy > 0 ? .standing : runner.posture
            velocity = Velocity(dx: velocity.dx, dy: 0)
        } else {
            runner.posture = isSupported(runner.box) ? .standing : .airborne
        }
        if case .standing = runner.posture, !isSupported(runner.box) {
            runner.posture = .airborne
        }
        runner.velocity = velocity
    }

    /// 足のすぐ下に乗れる物があるか（固い地形・梯子のいちばん上・動く足場）。
    func isSupported(_ box: Box) -> Bool {
        let below = box.moved(by: Velocity(dx: 0, dy: 1))
        return collides(below, before: box, movingDown: true) || landsOnPlatform(below, before: box)
    }

    /// 梯子の上り下り。梯子の上端を越えたら梯子の上に立ち、梯子が無くなったら落ちる。
    private mutating func moveClimber() {
        let moved = slide(runner.box, dx: 0, dy: runner.velocity.dy, carriesOntoPlatforms: false)
        runner.position = moved.box.origin
        guard ladderColumn(for: runner.box) == nil else {
            if moved.blocked, runner.velocity.dy > 0 {
                runner.posture = .standing
            }
            return
        }
        runner.posture = isSupported(runner.box) ? .standing : .airborne
        runner.velocity = .zero
    }

    /// 棘に触れたか、穴に落ちたら 1 機失う。
    mutating func checkHazards(events: inout [GameEvent]) {
        if runner.position.y > map.height {
            loseLife(.pit, events: &events)
        } else if touchesSpike(runner.box) {
            loseLife(.spike, events: &events)
        }
    }
}

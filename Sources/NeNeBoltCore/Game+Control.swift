/// 自機の操作（FR-02）。押されているボタンの組から、向き・速さ・梯子・跳ぶ・撃つを決める。人も AI も同じ経路（ARC-001）。
extension Game {
    /// 画面に同時に出せる自機の弾の数。
    public static let maxRunnerShots = 3
    /// 自機の弾の速さ。
    static let runnerShotSpeed = 8
    /// 自機の弾が消えるまでの刻み。
    static let runnerShotLife = 40
    /// 弾が出る高さ（足から・単位）。小さな敵の欠片にも当たる低さ。
    static let muzzleHeight = 7

    mutating func control(_ buttons: Buttons, events: inout [GameEvent]) {
        let pressed = buttons.subtracting(runner.held)
        let released = runner.held.subtracting(buttons)
        grabLadder(buttons)
        switch runner.posture {
        case .climbing:
            climb(buttons, pressed: pressed)
        case .standing, .airborne:
            steer(buttons)
            if pressed.contains(.jump), case .standing = runner.posture {
                runner.velocity = Velocity(dx: runner.velocity.dx, dy: -Runner.jumpSpeed)
                runner.posture = .airborne
            }
            if released.contains(.jump), runner.velocity.dy < -Runner.jumpCut {
                runner.velocity = Velocity(dx: runner.velocity.dx, dy: -Runner.jumpCut)
            }
        }
        trigger(buttons, pressed: pressed, released: released, events: &events)
    }

    /// 上か下を押していて、真ん中の列に梯子があればつかまる（下は足の下の梯子も見る）。
    private mutating func grabLadder(_ buttons: Buttons) {
        if case .climbing = runner.posture {
            return
        }
        let probe: Box
        if buttons.contains(.up) {
            probe = runner.box
        } else if buttons.contains(.down), case .standing = runner.posture {
            probe = runner.box.moved(by: Velocity(dx: 0, dy: 2))
        } else {
            return
        }
        guard let column = ladderColumn(for: probe) else {
            return
        }
        runner.position = Point(x: Field.units(column) + (Field.cellUnits - Runner.width) / 2, y: runner.position.y)
        runner.velocity = .zero
        runner.posture = .climbing
    }

    private mutating func climb(_ buttons: Buttons, pressed: Buttons) {
        if pressed.contains(.jump) {
            runner.posture = .airborne
            runner.velocity = .zero
            return
        }
        var dy = 0
        if buttons.contains(.up) {
            dy = -Runner.climbSpeed
        } else if buttons.contains(.down) {
            dy = Runner.climbSpeed
        }
        runner.velocity = Velocity(dx: 0, dy: dy)
    }

    /// 左右。滑る床の上では速さが 2 刻みに 1 ずつしか変わらない。
    private mutating func steer(_ buttons: Buttons) {
        var target = 0
        if buttons.contains(.left) {
            target -= Runner.runSpeed
            runner.facing = .left
        }
        if buttons.contains(.right) {
            target += Runner.runSpeed
            runner.facing = .right
        }
        var dx = runner.velocity.dx
        if case .standing = runner.posture, case .ice = footing(of: runner.box) {
            if stageTick % 2 == 0, dx != target {
                dx += dx < target ? 1 : -1
            }
        } else {
            dx = target
        }
        runner.velocity = Velocity(dx: dx, dy: runner.velocity.dy)
    }

    /// 撃つ: 押した瞬間にふつうの弾。押し続けて溜まってから離すと溜め撃ち。
    private mutating func trigger(
        _ buttons: Buttons, pressed: Buttons, released: Buttons, events: inout [GameEvent]
    ) {
        if pressed.contains(.fire) {
            fire(charged: false)
        }
        if buttons.contains(.fire) {
            runner.charge += 1
            return
        }
        if released.contains(.fire), runner.isCharged {
            fire(charged: true)
            events.append(.chargedShot)
        }
        runner.charge = 0
    }

    /// 撃てるか（画面の弾の数が上限より少ない）。
    public var canFire: Bool {
        shots.filter { $0.owner == .runner }.count < Game.maxRunnerShots
    }

    private mutating func fire(charged: Bool) {
        guard charged || canFire else {
            return
        }
        let size = charged ? (width: 12, height: 10) : (width: 6, height: 4)
        let box = runner.box
        let x = runner.facing.sign > 0 ? box.right : box.origin.x - size.width
        let shot = Shot(
            owner: .runner, position: Point(x: x, y: box.bottom - Game.muzzleHeight - size.height / 2),
            velocity: Velocity(dx: runner.facing.sign * Game.runnerShotSpeed, dy: 0), width: size.width,
            height: size.height, damage: charged ? 4 : 1 + runner.power, charged: charged, life: Game.runnerShotLife)
        shots.append(shot)
    }
}

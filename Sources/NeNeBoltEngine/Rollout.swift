import NeNeBoltCore

/// 先読みの 1 本（ADR 0008）。Core の `Game.step` でゲームを進め、出来事から値を積む。
struct Rollout {
    private(set) var state: Game
    private let route: Route
    private let persona: Persona
    private let difficulty: Difficulty
    private var calm = Calm()
    /// 体力を惜しむ重み（百分率）。制限時間が減るほど小さくなる（焦る）。
    private let caution: Int
    private var gathered = 0
    private var ticks = 0
    private var closest: Int
    private var closestAt = 0
    private var airborne = false
    /// 跳んで（落ちて）から、前より先の所に着いたか。続きの読みはここで打ち切る（着いた先からは、着いてから読み直す）。
    private(set) var landedAhead = false

    init(game: Game, route: Route, persona: Persona, difficulty: Difficulty) {
        state = game
        self.route = route
        self.persona = persona
        self.difficulty = difficulty
        closest = route.distance(from: game.runner.box)
        // 残り時間に比例して惜しまなくなる（最低でも性格の 1 割）。慎重な性格が敵の前で時間切れまで立ち止まらないように
        let left = max(game.timeLeft, 0)
        caution = max(persona.caution * left / Game.stageTime, persona.caution / 10)
    }

    /// 1 刻み進める。撃つは 4 刻みに 2 回押す。1 機を失うか面を終えたら、その値を返す（それ以上進めない）。
    mutating func advance(_ move: Buttons) -> Int? {
        var buttons = move
        if ticks % 4 < 2 {
            buttons.insert(.fire)
        }
        let step = state.step(buttons, difficulty: difficulty, using: &calm)
        ticks += 1
        for event in step.events {
            if let end = absorb(event) {
                return end
            }
        }
        state = step.game
        track()
        return nil
    }

    /// 出来事を 1 つ値に積む。1 機を失うか面を終えたら、その値を返す。
    private mutating func absorb(_ event: GameEvent) -> Int? {
        switch event {
        case .lifeLost:
            return -1_000_000 + ticks * 1_000
        case .runnerHit(let damage):
            gathered -= damage * 3 * caution
        case .pickedUp(let kind):
            gathered += Rollout.worth(of: kind) * persona.greed / 100
        case .enemyDefeated(_, let points, _, _):
            gathered += points / 4
        case .bossHit:
            gathered += 600
        case .stageCleared, .bossDefeated:
            return 1_000_000 - ticks * 1_000
        case .stageStarted, .timeBonus, .enemyHit, .chargedShot, .respawned, .coinsOneUp, .checkpointReached,
            .hurryUp, .bossAppeared, .bossFlash, .gameOver:
            break
        }
        return nil
    }

    /// 立てた（つかまれた）いちばん先の所と、跳んでから先へ着いたかを覚える。
    private mutating func track() {
        switch state.runner.posture {
        case .standing, .climbing:
            let distance = route.distance(from: state.runner.box)
            if distance < closest {
                closest = distance
                closestAt = ticks
                landedAhead = landedAhead || airborne
            }
            airborne = false
        case .airborne:
            airborne = true
        }
    }

    /// 続きの読みを始める（ここから先で着いたかを数え直す）。
    mutating func beginFollowUp() {
        landedAhead = false
    }

    /// ここまでの値。ボス戦の外では、立てた（つかまれた）いちばん先の所までの道のりの縮みで数え、そこへ着くのが遅いほど少し減らす
    /// （同じだけ進めるなら早い方を選ぶ。減らさないと、2 段目に同じ動きがあるので「待ってから」がいつまでも選ばれる）。
    func value(start game: Game) -> Int {
        var value = gathered
        switch state.boss {
        case .fighting:
            break
        case .waiting, .defeated:
            let start = route.distance(from: game.runner.box)
            value += (start - closest) * 120 + (start - route.distance(from: state.runner.box)) * 20 - closestAt * 6
        }
        if case .standing = state.runner.posture {
            value += 30
        }
        return value
    }

    /// 拾うものの値打ち（性格の欲で重みを付ける前）。
    private static func worth(of kind: PickupKind) -> Int {
        switch kind {
        case .coin: 150
        case .health: 400
        case .oneUp: 2_000
        case .powerUp: 800
        }
    }
}

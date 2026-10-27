import NeNeBoltCore

/// ランナーの AI（FR-04・ADR 0008）。Core の公開の状態を読み、押すボタンの組だけを返す（ARC-004）。
///
/// `replan` 刻みごとに、`Maneuver.all` の動きをそれぞれ 2 段（動き＋続き）で **Core の `Game.step` でそのまま進めてみて**、
/// 1 機を失わず、行き先へ近づき、性格の欲しがるものを取る動きを選ぶ。第 2 の物理を書かない（ARC-001）。
/// 先読みの乱数源は `Calm`。千分率 `blindness` の選び直しでは先を読まず、ただ行き先の方へ走るか跳ぶ（いつか必ず落ちる）。
public struct Pilot: Sendable {
    /// 走っている性格。
    public let persona: Persona
    private var route: Route?
    private var plan = Maneuver.all[0]
    private var elapsed = Int.max / 2

    /// 新しいゲームのランナー。
    public init(persona: Persona) {
        self.persona = persona
    }

    /// この刻みに押すボタン。
    public mutating func buttons(
        for game: Game, difficulty: Difficulty, using generator: inout some RandomNumberGenerator
    ) -> Buttons {
        guard case .playing = game.phase else {
            elapsed = Int.max / 2
            return []
        }
        if route?.stage != game.stage.number {
            route = Route.make(for: game)
        }
        // 助走（待つ間）のある動きは、跳び始めるまで選び直さない。選び直すと助走がいつまでも終わらない
        if elapsed >= max(persona.replan, plan.delay + 2) {
            plan = choose(game, difficulty: difficulty, using: &generator)
            elapsed = 0
        }
        var buttons = plan.buttons(at: elapsed)
        elapsed += 1
        buttons.formUnion(fire(game))
        return buttons
    }

    /// 次の動きを選ぶ。
    func choose(
        _ game: Game, difficulty: Difficulty, using generator: inout some RandomNumberGenerator
    ) -> Maneuver {
        guard let route else {
            return Maneuver.all[0]
        }
        if Int.random(in: 0..<1_000, using: &generator) < persona.blindness {
            return Maneuver.all[Int.random(in: 0..<3, using: &generator)]
        }
        var best = Maneuver.all[0]
        var bestValue = Int.min
        for maneuver in Maneuver.all {
            let value = evaluate(maneuver, game: game, route: route, difficulty: difficulty)
            if value > bestValue {
                bestValue = value
                best = maneuver
            }
        }
        return best
    }

    /// 動きを試した値（2 段の先読み）。まず動きの前半（待つ間と跳ぶ間・`Maneuver.span`）を進め、その先は `Maneuver.followUps` の
    /// どれかで `horizon` 刻み続けて、いちばん良い続きの値を足す。乗った消える足場が消える前に次へ跳ぶ、という連なりを読むため。
    /// 続きは、跳んで前より先の所に着いたら打ち切る（その先で足場が消えても、着いてから読み直す）。
    /// 1 機を失うなら、失うのが遅いほど少しましな大きな負の値。
    func evaluate(_ maneuver: Maneuver, game: Game, route: Route, difficulty: Difficulty) -> Int {
        var first = Rollout(game: game, route: route, persona: persona, difficulty: difficulty)
        for elapsed in 0..<(maneuver.delay + Maneuver.span) {
            if let end = first.advance(maneuver.buttons(at: elapsed)) {
                return end
            }
        }
        var best = Int.min
        for followUp in Maneuver.followUps {
            var second = first
            second.beginFollowUp()
            var ended: Int?
            for elapsed in 0..<persona.horizon {
                ended = second.advance(followUp.buttons(at: elapsed))
                if ended != nil || second.landedAhead {
                    break
                }
            }
            best = max(best, ended ?? second.value(start: game))
        }
        return best
    }

    /// 撃つかどうか。連射は前に敵（かボス）がいれば撃ち、溜め撃ちは押し続けて、溜まって前に来たら離す。
    private func fire(_ game: Game) -> Buttons {
        let target = Pilot.targetAhead(game)
        switch persona.trigger {
        case .rapid:
            return target && game.tick % 4 < 2 ? .fire : []
        case .charge:
            if game.runner.isCharged, target {
                return []
            }
            return .fire
        }
    }

    /// 自機の向いている側の、同じ高さの 14 セル以内に敵かボスがいるか。
    static func targetAhead(_ game: Game) -> Bool {
        let box = game.runner.box
        let sign = game.runner.facing.sign
        let reach = Field.units(14)
        func ahead(_ other: Box) -> Bool {
            let dx = (other.centerX - box.centerX) * sign
            return dx > 0 && dx < reach && other.origin.y < box.bottom && box.origin.y < other.bottom
        }
        if case .fighting(let boss) = game.boss, ahead(boss.box) {
            return true
        }
        return game.enemies.contains { $0.isSolid && ahead($0.box) }
    }
}

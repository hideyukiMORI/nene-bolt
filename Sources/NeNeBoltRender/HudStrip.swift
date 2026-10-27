import NeNeBoltCore

/// 面の窓の下の 2 行の HUD（FR-10）。
///
/// 1 行目: スコア・1 位・面・残機・体力のゲージ・コイン・パワーアップの段。
/// 2 行目: 残り時間・難易度・誰が操作しているか・キー入力の方式・通算のゲーム数。
struct HudStrip {
    let state: ScreenState
    let glyphs: FrameGlyphs

    /// 2 行。
    func lines() -> [[Segment]] {
        let theme = state.display.theme
        let game = state.playing
        let score = game?.score ?? lastScore
        let first: [Segment] =
            pair("SCORE", Wording.digits(score, 7))
            + pair("HI", Wording.digits(max(state.highScores.best, score), 7))
            + pair("STAGE", game.map { String($0.stage.number) } ?? "-")
            + pair("LIVES", game.map { Wording.digits($0.lives, 2) } ?? "--")
            + [Segment("HP ", theme.dim)] + gauge(game) + [Segment("  ", theme.dim)]
            + pair("COIN", game.map { Wording.digits($0.coins, 2) } ?? "--")
            + pair("POW", game.map { String($0.runner.power) } ?? "-")
        let pilotColor: Rgb
        switch state.pilot {
        case .autopilot: pilotColor = theme.text
        case .player: pilotColor = theme.accentAlt
        }
        let second: [Segment] =
            pair("TIME", game.map { Wording.digits(max($0.timeLeft, 0) / 30, 3) } ?? "---")
            + pair("LEVEL", Wording.difficulty(state.difficulty))
            + [Segment("PILOT ", theme.dim), Segment(Wording.pilot(state.pilot) + "  ", pilotColor)]
            + pair("KEYS", Wording.keys(state.keys))
            + pair("GAME", Wording.digits(state.gameNumber, 3))
        return [[Segment(" ", theme.dim)] + first, [Segment(" ", theme.dim)] + second]
    }

    /// 体力のゲージ（10 目盛り）。
    private func gauge(_ game: Game?) -> [Segment] {
        let theme = state.display.theme
        let health = game?.runner.health ?? 0
        let full = String(repeating: glyphs.barFull, count: health)
        let empty = String(repeating: glyphs.barEmpty, count: Runner.maxHealth - health)
        let color = health <= 3 ? theme.danger : theme.runner
        return [Segment(full, color), Segment(empty, theme.dim)]
    }

    private var lastScore: Int {
        switch state.session.scene {
        case .gameOver(let summary, _), .ending(let summary, _): summary.score
        case .title, .play: 0
        }
    }

    private func pair(_ label: String, _ value: String) -> [Segment] {
        let theme = state.display.theme
        return [Segment(label + " ", theme.dim), Segment(value + "  ", theme.text)]
    }
}

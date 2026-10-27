import NeNeBoltCore

/// ランナーのセリフ（COMMS）の状態。どの出来事で話すかの規則はここだけにある（FR-06・ADR 0009）。
///
/// - 1 刻みに 1 行まで。その刻みでいちばん優先度の高いきっかけだけを見て、確率に外れたら黙る
/// - 必ず言うきっかけ（1 機失った・最後の 1 機・急かされた・ボス・GAME OVER・新記録・TITLE）以外は、前の発言から `quietTicks` 刻みは黙る
/// - 同じランナーは直近 8 回と同じセリフを言わない
/// - 乱数は引数から受け取るので、同じシードからは同じ会話になる
/// 移植元: NeNe Swarm `Sources/NeNeSwarmEngine/Banter.swift`（コミット a660f47）。出来事を横スクロールのものに替えた。
public struct Banter: Sendable, Hashable {
    /// 間を置く刻みの数（30 刻み／秒で 3 秒）。
    static let quietTicks = 90
    /// 続けて倒したと数える間（刻み）と数。
    static let streakWindow = 60
    static let streakCount = 3

    /// 直近の発言（古い順・最大 2 つ）。
    public private(set) var lines: [Remark] = []

    /// いちばん新しい発言（まだ無ければ nil）。
    public var latest: Remark? { lines.last }
    private var recent: [String: [String]] = [:]
    private var clock = 0
    private var lastSpoke = -quietTicks
    private var kills: [Int] = []

    /// 何も言っていない状態。
    public init() {}

    /// 1 刻みに聞いたことに反応する（0〜1 行）。
    public mutating func listen(
        _ hearing: Hearing, persona: Persona, using generator: inout some RandomNumberGenerator
    ) {
        clock += 1
        let cues = notice(hearing)
        guard let cue = cues.max(by: { $0.priority < $1.priority }) else {
            return
        }
        let roll = Int.random(in: 0..<100, using: &generator)
        guard roll < cue.chance, cue.interrupts || clock - lastSpoke >= Banter.quietTicks else {
            return
        }
        say(cue, persona: persona, using: &generator)
    }

    /// 出来事からきっかけを拾う。続けて倒した数はここで数える。
    private mutating func notice(_ hearing: Hearing) -> [Cue] {
        var cues: [Cue] = []
        for event in hearing.events {
            cues += cuesHeard(in: event, hearing: hearing)
        }
        kills = kills.filter { clock - $0 < Banter.streakWindow }
        if kills.count >= Banter.streakCount {
            cues.append(.streak)
            kills.removeAll()
        }
        return cues
    }

    private mutating func cuesHeard(in event: SessionEvent, hearing: Hearing) -> [Cue] {
        switch event {
        case .titleShown: return [.title]
        case .gameStarted: return []
        case .gameEnded: return [hearing.newRecord ? .newRecord : .gameOver]
        case .game(let inner): return cuesHeard(in: inner, lives: hearing.lives)
        }
    }

    private mutating func cuesHeard(in event: GameEvent, lives: Int?) -> [Cue] {
        switch event {
        case .enemyDefeated:
            kills.append(clock)
            return []
        case .respawned:
            return lives == 1 ? [.lastLife] : []
        case .pickedUp(let kind):
            return Banter.cue(picking: kind).map { [$0] } ?? []
        case .stageStarted, .stageCleared, .coinsOneUp, .runnerHit, .lifeLost, .hurryUp, .bossAppeared, .bossDefeated,
            .timeBonus, .enemyHit, .chargedShot, .checkpointReached, .bossHit, .bossFlash, .gameOver:
            return Banter.cue(for: event).map { [$0] } ?? []
        }
    }

    /// 数えずにそのまま決まるきっかけ。
    private static func cue(for event: GameEvent) -> Cue? {
        switch event {
        case .stageStarted: .stageStart
        case .stageCleared: .stageClear
        case .coinsOneUp: .powerUp
        case .runnerHit: .hit
        case .lifeLost: .lifeLost
        case .hurryUp: .hurryUp
        case .bossAppeared: .bossAppeared
        case .bossDefeated: .bossDefeated
        case .enemyDefeated, .respawned, .pickedUp, .timeBonus, .enemyHit, .chargedShot, .checkpointReached, .bossHit,
            .bossFlash, .gameOver:
            nil
        }
    }

    /// 拾ったもののきっかけ（パワーアップと 1UP だけ話す）。
    private static func cue(picking kind: PickupKind) -> Cue? {
        switch kind {
        case .powerUp, .oneUp: .powerUp
        case .coin, .health: nil
        }
    }

    /// 1 行を言う。直近 8 回のセリフを避けて乱数で選ぶ（全部が直近なら避けない）。
    private mutating func say(_ cue: Cue, persona: Persona, using generator: inout some RandomNumberGenerator) {
        let all = persona.lines(for: cue)
        let said = recent[persona.name] ?? []
        let fresh = all.filter { !said.contains($0) }
        guard let text = (fresh.isEmpty ? all : fresh).randomElement(using: &generator) else {
            return
        }
        recent[persona.name] = Array((said + [text]).suffix(8))
        lastSpoke = clock
        lines = Array((lines + [Remark(persona: persona, cue: cue, text: text)]).suffix(2))
    }
}

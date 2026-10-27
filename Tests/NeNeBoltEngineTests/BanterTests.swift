import Testing

@testable import NeNeBoltCore
@testable import NeNeBoltEngine

/// セリフ（FR-06・ADR 0009）。
struct BanterTests {
    /// きっかけごとの本数（1 人 50 本）。
    static let counts: [Cue: Int] = [
        .title: 5, .stageStart: 5, .stageClear: 4, .streak: 4, .powerUp: 4, .hit: 5, .lifeLost: 5, .lastLife: 3,
        .hurryUp: 3, .bossAppeared: 4, .bossDefeated: 3, .gameOver: 3, .newRecord: 2,
    ]

    @Test(arguments: Persona.roster)
    func everyRunnerHasFiftyDistinctLinesForEveryCue(_ persona: Persona) {
        #expect(persona.script.count == 50)
        #expect(Set(persona.script.map(\.text)).count == 50)
        for cue in Cue.allCases {
            #expect(persona.lines(for: cue).count == Self.counts[cue], "\(persona.name) \(cue)")
        }
    }

    /// COMMS の 1 行に顔と並んで入る（72 文字以内）。英語の ASCII だけで、文字の幅が端末で変わらない。
    @Test(arguments: Persona.roster)
    func everyLineFitsTheCommsRowInPlainAscii(_ persona: Persona) {
        for line in persona.script {
            #expect(line.text.count <= 72, "\(line.text)")
            #expect(line.text.unicodeScalars.allSatisfy { $0.isASCII && $0.value >= 0x20 }, "\(line.text)")
        }
    }

    static func hearing(_ events: [GameEvent], lives: Int? = 4) -> Hearing {
        Hearing(events: events.map(SessionEvent.game), lives: lives, newRecord: false)
    }

    /// 必ず言うきっかけは、直前に話していても言う。
    @Test func mustSayCuesAlwaysSpeak() {
        var banter = Banter()
        var generator = SplitMix64(seed: 3)
        banter.listen(Self.hearing([.bossAppeared]), persona: .dash, using: &generator)
        #expect(banter.latest?.cue == .bossAppeared)
        banter.listen(Self.hearing([.lifeLost(.pit)]), persona: .dash, using: &generator)
        #expect(banter.latest?.cue == .lifeLost)
        banter.listen(Self.hearing([.respawned], lives: 1), persona: .dash, using: &generator)
        #expect(banter.latest?.cue == .lastLife)
        #expect(banter.lines.count == 2)
    }

    /// 同じ刻みにいくつあっても 1 行。優先度の高い方を言う。
    @Test func oneLinePerTickAndTheHigherPriorityWins() {
        var banter = Banter()
        var generator = SplitMix64(seed: 5)
        banter.listen(Self.hearing([.runnerHit(damage: 3), .lifeLost(.health)]), persona: .glitch, using: &generator)
        #expect(banter.lines.count == 1)
        #expect(banter.latest?.cue == .lifeLost)
    }

    /// 必ず言うのでないきっかけは、話したすぐあとは黙る。
    @Test func optionalCuesWaitForTheQuietGap() {
        var banter = Banter()
        var generator = SplitMix64(seed: 7)
        banter.listen(Self.hearing([.bossAppeared]), persona: .hoard, using: &generator)
        for _ in 0..<20 {
            banter.listen(Self.hearing([.runnerHit(damage: 2)]), persona: .hoard, using: &generator)
        }
        #expect(banter.lines.count == 1)
    }

    /// 同じシードなら同じ会話になる（FR-05）。
    @Test func theSameSeedGivesTheSameConversation() {
        func talk() -> [Remark] {
            var banter = Banter()
            var generator = SplitMix64(seed: 11)
            var said: [Remark] = []
            for tick in 0..<2_000 {
                let events: [GameEvent] =
                    tick % 97 == 0 ? [.lifeLost(.spike)] : (tick % 13 == 0 ? [.runnerHit(damage: 2)] : [])
                banter.listen(Self.hearing(events), persona: .patient, using: &generator)
                if let latest = banter.latest, said.last != latest {
                    said.append(latest)
                }
            }
            return said
        }
        let first = talk()
        #expect(first.count > 10)
        #expect(first == talk())
    }

    /// TITLE と GAME OVER と新記録は場面の出来事から拾う。
    @Test func sceneEventsBecomeCues() {
        var banter = Banter()
        var generator = SplitMix64(seed: 13)
        banter.listen(Hearing(events: [.titleShown], lives: nil, newRecord: false), persona: .dash, using: &generator)
        #expect(banter.latest?.cue == .title)
        let summary = GameSummary(
            score: 10, stage: Stage(number: 2), ending: .outOfLives, difficulty: .normal, ticks: 9)
        banter.listen(
            Hearing(events: [.gameEnded(summary)], lives: nil, newRecord: true), persona: .dash, using: &generator)
        #expect(banter.latest?.cue == .newRecord)
    }
}

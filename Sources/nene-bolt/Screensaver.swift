import NeNeBoltCore
import NeNeBoltEngine
import NeNeBoltRender
import NeNeBoltTerminal

/// 場面の列を一定の刻みで回す 1 本のループ（ADR 0007）。状態はすべてこの値の中にあり、ループの外へ出ない（ARC-005）。
///
/// 時計を読むのはここだけ。Core は刻みの数しか知らないので、同じシードならキーを押さない限り刻みの速さによらず同じゲームになる。
/// 人と AI は同じ `Buttons` を同じ `Session.step` に渡す（ADR 0004）。どちらが操作しているかは `Controls` が決める。
/// 移植元: NeNe Swarm `Sources/nene-swarm/Screensaver.swift`（コミット a660f47）。セリフと演出を落とし、人の操作を足した。
/// ランナーは TITLE に入るたびに 4 名から乱数で選び、次のゲームで走らせる（FR-06・ADR 0008）。
struct Screensaver {
    /// 描くのが遅れたときに追いつく刻みの上限（それ以上は捨てて、いまから数え直す）。
    private static let maxCatchUp = 4
    /// ハイスコアの表に人の記録を残すときの名前（FR-02g）。
    private static let playerName = "PLAYER"

    private let options: LaunchOptions
    private let seed: UInt64
    private let clock = ContinuousClock()
    private let started: ContinuousClock.Instant
    private var generator: SplitMix64
    private var pilotGenerator: SplitMix64
    private var persona: Persona
    private var pilot: Pilot
    private var controls: Controls
    private var humanPlayedThisGame = false
    private var session: Session
    private var display: DisplayOptions
    private var difficulty: Difficulty
    private var highScores = HighScoreTable.empty
    private var storage = ScoreStorage.memoryOnly
    private var previous: Grid?

    init(options: LaunchOptions, display: DisplayOptions, seed: UInt64) {
        self.options = options
        self.display = display
        self.seed = seed
        started = clock.now
        difficulty = options.difficulty
        generator = SplitMix64(seed: seed)
        pilotGenerator = SplitMix64(seed: seed ^ 0x424F_4C54_2121)
        controls = Controls(handBack: options.handBack)
        session = Session(durations: options.durations)
        switch ScoreStore.load() {
        case .loaded(let table):
            highScores = table
            storage = .file
        case .memoryOnly:
            storage = .memoryOnly
        }
        persona = Persona.roster.randomElement(using: &pilotGenerator) ?? Persona.dash
        pilot = Pilot(persona: persona)
    }

    /// `q` か終了のシグナルが来るまで回す。
    mutating func run() {
        var next = clock.now + options.tickInterval
        draw()
        while true {
            let bytes = Console.waitForInput(milliseconds: milliseconds(until: next))
            let commands = controls.receive(bytes, at: now)
            let signals = Console.takeSignals()
            if signals.interrupted || commands.contains(.quit) {
                return
            }
            apply(commands)
            if signals.resized {
                previous = nil
            }
            var steps = 0
            while clock.now >= next, steps < Self.maxCatchUp {
                tick()
                next += options.tickInterval
                steps += 1
            }
            if clock.now >= next {
                next = clock.now + options.tickInterval
            }
            draw()
        }
    }

    private mutating func apply(_ commands: [Controls.Command]) {
        for command in commands {
            switch command {
            case .quit:
                return
            case .cycleTheme:
                display = display.cyclingTheme
            case .cycleDifficulty:
                difficulty = difficulty.next
            }
        }
    }

    /// 1 刻み進める。PLAY の間だけ、人か AI のどちらかがボタンを決める。
    private mutating func tick() {
        let moment = now
        let pressed = controls.buttons(at: moment)
        var buttons: Buttons = []
        if case .play(let game) = session.scene {
            if controls.isHuman(at: moment) {
                buttons = pressed
                humanPlayedThisGame = true
            } else {
                buttons = pilot.buttons(for: game, difficulty: difficulty, using: &pilotGenerator)
            }
        }
        let step = session.step(buttons, difficulty: difficulty, using: &generator)
        for event in step.events {
            record(event)
        }
        session = step.session
    }

    /// 出来事を 1 つ反映する。
    private mutating func record(_ event: SessionEvent) {
        switch event {
        case .gameStarted:
            pilot = Pilot(persona: persona)
            humanPlayedThisGame = false
        case .gameEnded(let summary):
            let name = humanPlayedThisGame ? Self.playerName : persona.name
            let entry = HighScore(
                score: summary.score, pilot: name, stage: summary.stage.number, difficulty: summary.difficulty)
            highScores = highScores.inserting(entry).table
            if case .file = storage, !ScoreStore.save(highScores) {
                storage = .memoryOnly
            }
        case .titleShown:
            // 次のゲームのランナーは TITLE に入ったときに決め、TITLE に出す
            persona = Persona.roster.randomElement(using: &pilotGenerator) ?? Persona.dash
        case .game:
            break
        }
    }

    /// いまの状態を描き、前のフレームとの差分だけを 1 回で書く。
    private mutating func draw() {
        let moment = now
        let pilot: PilotLabel =
            controls.secondsLeft(at: moment).map { .player(secondsLeft: $0) }
            ?? .autopilot(name: persona.name)
        let state = ScreenState(
            session: session, display: display, difficulty: difficulty, seed: seed, highScores: highScores,
            pilot: pilot, keys: controls.reading, storage: storage)
        let grid = ScreenRenderer.render(state, size: Console.size())
        Console.write(FrameEncoder.encode(grid, previous: previous, colors: display.traits.colors))
        previous = grid
    }

    /// 起動からのミリ秒。
    private var now: Int {
        let (seconds, attoseconds) = (clock.now - started).components
        return Int(seconds * 1000 + attoseconds / 1_000_000_000_000_000)
    }

    /// 締め切りまでのミリ秒（過ぎていれば 0）。
    private func milliseconds(until instant: ContinuousClock.Instant) -> Int32 {
        let (seconds, attoseconds) = (instant - clock.now).components
        let total = seconds * 1000 + attoseconds / 1_000_000_000_000_000
        return Int32(clamping: max(total, 0))
    }
}

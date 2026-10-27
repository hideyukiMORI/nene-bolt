/// 1 ゲームの状態（ADR 0005）。ゲームを進めるのは `step` の 1 経路だけで、秒を知らない（ARC-007）。
///
/// 外からは読むだけ。人も AI も `Buttons` だけを渡し、状態を書き換えない（ARC-004）。
/// 「当たったか」「面を終えたか」「ゲームが終わったか」の判定は、どれもこの型の中に 1 つずつある（ARC-001）。
public struct Game: Sendable, Hashable {
    /// 刻みの数の上限（30 刻み／秒で 20 分）。届いたら `.timeLimit` で終わる。
    public static let tickLimit = 36_000
    /// 始まりの残機（いま走っている 1 機を除く）。
    public static let startingReserve = 3
    /// 1 回の挑戦の制限時間（30 刻み／秒で 180 秒）。
    public static let stageTime = 5_400
    /// 1UP になるコインの数。
    public static let coinsPerLife = 100
    /// ボスを倒したときの得点。
    public static let bossPoints = 5_000
    static let introTicks = 45
    static let dyingTicks = 60
    static let clearedTicks = 90
    static let victoryTicks = 150
    static let explosionTicks = 10

    /// いまの面。
    public internal(set) var stage: Stage
    /// 面の地図。
    public internal(set) var map: StageMap
    /// 面の中の段階。
    public internal(set) var phase: PlayPhase
    /// 続いているか。
    public internal(set) var status: GameStatus
    /// 自機。
    public internal(set) var runner: Runner
    /// 残機（いま走っている 1 機を除く）。
    public internal(set) var reserve: Int
    /// コイン（100 枚で 0 に戻る）。
    public internal(set) var coins: Int
    /// スコア。減らない。
    public internal(set) var score: Int
    /// 敵（爆発中を含む）。
    public internal(set) var enemies: [Enemy]
    /// 弾（自機の弾と敵の弾）。
    public internal(set) var shots: [Shot]
    /// 拾うもの。
    public internal(set) var pickups: [Pickup]
    /// 動く足場。
    public internal(set) var platforms: [Platform]
    /// ボス。
    public internal(set) var boss: BossState
    /// ボスの部屋の扉が閉じているか。
    public internal(set) var doorClosed: Bool
    /// やり直す位置（始まりか中間地点）。
    public internal(set) var checkpoint: Spawn
    /// 面（いまの挑戦）が始まってからの刻み。消える足場の時計。
    public internal(set) var stageTick: Int
    /// 制限時間の残りの刻み。
    public internal(set) var timeLeft: Int
    /// ゲームが始まってからの刻み。
    public internal(set) var tick: Int
    /// 次に生まれる敵の番号。
    var nextEnemyID: Int

    /// 1 面の始まりのゲームを作る。
    public init() {
        let first = Stage(number: 1)
        let map = StageCatalog.map(of: first)
        let start = map.first(.start) ?? Spawn(kind: .start, column: 1, row: 1)
        stage = first
        self.map = map
        phase = .intro(ticksLeft: Game.introTicks)
        status = .running
        runner = Runner.standing(on: start)
        reserve = Game.startingReserve
        coins = 0
        score = 0
        enemies = []
        shots = []
        pickups = []
        platforms = []
        boss = .waiting
        doorClosed = false
        checkpoint = start
        stageTick = 0
        timeLeft = Game.stageTime
        tick = 0
        nextEnemyID = 0
        var events: [GameEvent] = []
        load(first, events: &events)
    }

    /// 1 刻み進める。乱数は引数の乱数源からだけ引く（ARC-007）。終わったゲームは変わらない。
    public func step(
        _ buttons: Buttons, difficulty: Difficulty, using generator: inout some RandomNumberGenerator
    ) -> GameStep {
        var next = self
        var events: [GameEvent] = []
        if case .running = status {
            next.advance(
                buttons, tuning: Tuning.make(difficulty: difficulty, stage: stage), using: &generator, events: &events)
        }
        return GameStep(game: next, events: events)
    }

    /// 残機といま走っている 1 機を合わせた数（HUD と数の保存のテスト）。
    public var lives: Int {
        switch phase {
        case .dying: reserve
        case .intro, .playing, .cleared, .victory: reserve + 1
        }
    }
}

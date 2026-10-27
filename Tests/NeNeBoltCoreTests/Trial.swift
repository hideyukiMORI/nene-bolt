@testable import NeNeBoltCore

/// 回すゲームの条件（始める面・難易度・テストのランナー）。
struct Trial: Sendable, CustomStringConvertible {
    let stage: Int
    let difficulty: Difficulty
    let runner: TestRunner

    var description: String { "stage \(stage) \(difficulty) \(runner)" }

    /// 1 面から始める。
    static func fromStart(_ runner: TestRunner, _ difficulty: Difficulty) -> Trial {
        Trial(stage: 1, difficulty: difficulty, runner: runner)
    }
}

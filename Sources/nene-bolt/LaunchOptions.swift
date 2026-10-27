import NeNeBoltCore
import NeNeBoltRender

/// 起動オプション（ARC-008: 境界で 1 度だけ検証し、型に変えてから中へ渡す）。
///
/// `--seed <0 以上の整数>` / `--theme <名前>` / `--difficulty easy|normal|hard` / `--tick-rate <1 秒の刻みの数>` /
/// `--title-pause <秒>` / `--game-over-pause <秒>` / `--hand-back <秒>`（FR-11・FR-13・FR-14・FR-04a）。
/// 移植元: NeNe Swarm `Sources/nene-swarm/LaunchOptions.swift`（コミット a660f47）。AI に戻るまでの秒を足した。
struct LaunchOptions {
    /// 乱数のシード。与えられなければ nil（起動時にシステムの乱数から決める）。
    var seed: UInt64?
    var theme = Theme.standard
    var difficulty = Difficulty.normal
    /// 1 秒の刻みの数（ADR 0007 の計測で初期値を決めた）。
    var tickRate = 30
    /// TITLE を見せる時間（ミリ秒）。
    var titlePause = 5000
    /// GAME OVER と ENDING を見せる時間（ミリ秒）。
    var gameOverPause = 4000
    /// 人が何も押さなくなってから AI に戻るまでの時間（ミリ秒・FR-04a）。
    var handBack = 30_000

    /// 起動オプションを読む（プログラム名を除いた引数）。
    static func parse(_ arguments: [String]) -> LaunchParsing {
        var options = LaunchOptions()
        var rest = arguments[...]
        while let name = rest.popFirst() {
            guard let value = rest.popFirst() else {
                return .rejected("\(name) に値が無い")
            }
            guard let next = options.setting(name, value) else {
                return .rejected(
                    "読めないオプション: \(name) \(value)（--seed / --theme / --difficulty / --tick-rate / --title-pause / "
                        + "--game-over-pause / --hand-back）"
                )
            }
            options = next
        }
        return .parsed(options)
    }

    /// 1 刻みの長さ。
    var tickInterval: Duration {
        .nanoseconds(1_000_000_000 / tickRate)
    }

    /// 場面の長さを刻みの数に直したもの（どちらも 1 刻み以上）。
    var durations: SceneDurations {
        SceneDurations(
            titleTicks: max(1, titlePause * tickRate / 1000), gameOverTicks: max(1, gameOverPause * tickRate / 1000))
    }

    /// 文字列で分岐するので `switch` ではなく `if` で書く（SWF-002: 全捕捉を書かない）。
    private func setting(_ name: String, _ value: String) -> LaunchOptions? {
        var next = self
        if name == "--seed", let seed = UInt64(value) {
            next.seed = seed
        } else if name == "--theme", let theme = Theme.named(value) {
            next.theme = theme
        } else if name == "--difficulty", let difficulty = Self.difficulty(value) {
            next.difficulty = difficulty
        } else if name == "--tick-rate", let rate = Int(value), (10...60).contains(rate) {
            next.tickRate = rate
        } else if name == "--title-pause", let pause = Self.milliseconds(value) {
            next.titlePause = pause
        } else if name == "--game-over-pause", let pause = Self.milliseconds(value) {
            next.gameOverPause = pause
        } else if name == "--hand-back", let pause = Self.milliseconds(value) {
            next.handBack = pause
        } else {
            return nil
        }
        return next
    }

    private static func difficulty(_ text: String) -> Difficulty? {
        Difficulty.allCases.first { DifficultyLabel.text($0) == text.uppercased() }
    }

    /// 0.5〜60 秒の秒数をミリ秒に。
    private static func milliseconds(_ text: String) -> Int? {
        guard let seconds = Double(text), (0.5...60).contains(seconds) else {
            return nil
        }
        return Int((seconds * 1000).rounded())
    }
}

import NeNeBoltCore

/// 画面の文言（英語・ASCII だけ）。文言を持つのはここだけ。
enum Wording {
    static let title = "NENE//BOLT"
    /// TITLE の大きな文字（`/` は点の字形に無い）。
    static let bigTitle = "NENE BOLT"
    static let tagline = "A SIDE-SCROLLER THAT PLAYS ITSELF"
    static let takeOver = "PRESS ARROWS, Z OR X TO TAKE OVER"
    static let quitKey = "[q]"
    static let quitName = " QUIT  "
    static let themeKey = "[t]"
    static let themeName = " THEME "
    static let difficultyKey = "[d]"
    static let difficultyName = " "
    static let playKeys = "  ARROWS MOVE  Z JUMP  X FIRE"

    static func game(_ number: Int) -> String {
        "GAME " + digits(number, 3)
    }

    static func seed(_ seed: UInt64) -> String {
        let hex = String(seed, radix: 16, uppercase: true)
        return "SEED 0x" + String(repeating: "0", count: max(16 - hex.count, 0)) + hex
    }

    static func colors(_ mode: ColorMode) -> String {
        switch mode {
        case .trueColor: "24BIT"
        case .palette256: "256"
        }
    }

    static func difficulty(_ difficulty: Difficulty) -> String {
        switch difficulty {
        case .easy: "EASY"
        case .normal: "NORMAL"
        case .hard: "HARD"
        }
    }

    static func ending(_ ending: GameEnding) -> String {
        switch ending {
        case .cleared: "THE LAST GUARDIAN FELL"
        case .outOfLives: "OUT OF LIVES"
        case .timeLimit: "TIME UP"
        }
    }

    static func pilot(_ label: PilotLabel) -> String {
        switch label {
        case .autopilot(let name, _): "AUTO " + name
        case .player(let secondsLeft): "PLAYER " + digits(secondsLeft, 2) + "s"
        }
    }

    /// TITLE に出す次のランナー（顔つき）。
    static func nextRunner(_ label: PilotLabel) -> String {
        switch label {
        case .autopilot(let name, let face): "NEXT RUNNER " + name + " " + face
        case .player: pilot(label)
        }
    }

    static func keys(_ reading: KeyReading) -> String {
        switch reading {
        case .unknown: "--"
        case .pressAndRelease: "PRESS/RELEASE"
        case .repeatOnly: "REPEAT"
        }
    }

    static func stageBanner(_ stage: Stage) -> String {
        "STAGE " + String(stage.number)
    }

    static func stageName(_ stage: Stage) -> String {
        switch stage.kind {
        case .grassland: "GRASSLAND"
        case .cavern: "CRYSTAL CAVERN"
        case .sky: "SKY BRIDGES"
        case .fortress: "FORTRESS"
        }
    }

    static let stageClear = "CLEAR!"
    static let victory = "VICTORY"
    static let hurryUp = "HURRY UP!"
    static let gameOver = "GAME OVER"
    static let allClear = "ALL CLEAR"
    static let highScores = "HIGH SCORES"
    static let newRecord = "NEW RECORD"
    static let standby = "STANDBY"
    static let memoryOnly = "SCORES KEPT IN MEMORY ONLY"

    static func tooSmall(need: ScreenSize) -> String {
        "TERMINAL TOO SMALL: NEED \(need.columns)x\(need.rows)"
    }

    /// 0 で左を埋めた `width` 桁の数（収まらなければそのまま）。
    static func digits(_ value: Int, _ width: Int) -> String {
        let text = String(value)
        return String(repeating: "0", count: max(width - text.count, 0)) + text
    }
}

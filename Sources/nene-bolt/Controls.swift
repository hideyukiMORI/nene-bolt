import NeNeBoltCore
import NeNeBoltRender
import NeNeBoltTerminal

/// 人のキーと、誰が操作しているか（FR-04a・FR-04b・ADR 0007）。キーとボタンの対応は遊びの決まりなので合成ルートが持つ（ADR 0004）。
///
/// 遊びのキー（矢印・Z・X・空白）のどれかが届いた瞬間から人の操作になり、`handBack` ミリ秒なにも押さなければ AI に戻る。
/// 押す・離すを受け取る方式では、押しっぱなしの間も「押している」に数える。
struct Controls {
    /// スクリーンセーバーのキー。
    enum Command {
        case quit
        case cycleTheme
        case cycleDifficulty
    }

    private let handBack: Int
    private var held = HeldKeys()
    private var lastHuman: Int?
    private(set) var reading = KeyReading.unknown

    init(handBack: Int) {
        self.handBack = handBack
    }

    /// 届いたバイト列を反映し、スクリーンセーバーのキーを返す（届いた順）。
    mutating func receive(_ bytes: [UInt8], at now: Int) -> [Command] {
        let decoding = KeyDecoder.decode(bytes)
        if decoding.reportsReleases {
            reading = .pressAndRelease
        }
        var commands: [Command] = []
        for event in decoding.events {
            if let command = Controls.command(event) {
                commands.append(command)
                continue
            }
            guard Controls.button(for: event.key) != nil else {
                continue
            }
            switch event {
            case .typed:
                if case .unknown = reading {
                    reading = .repeatOnly
                }
                lastHuman = now
            case .pressed:
                lastHuman = now
            case .released:
                break
            }
            held.apply(event, at: now)
        }
        return commands
    }

    /// 人が操作しているか。
    func isHuman(at now: Int) -> Bool {
        lastHuman.map { now - $0 < handBack } ?? false
    }

    /// AI に戻るまでの残りの秒（人が操作していなければ nil）。
    func secondsLeft(at now: Int) -> Int? {
        guard let lastHuman, isHuman(at: now) else {
            return nil
        }
        return (lastHuman + handBack - now + 999) / 1_000
    }

    /// この刻みに人が押しているボタン。押しっぱなしも人の操作に数える。
    mutating func buttons(at now: Int) -> Buttons {
        let keys = held.take(at: now)
        var buttons: Buttons = []
        for key in keys {
            if let button = Controls.button(for: key) {
                buttons.insert(button)
            }
        }
        if !buttons.isEmpty, case .pressAndRelease = reading {
            lastHuman = now
        }
        return buttons
    }

    /// キーとボタンの対応（FR-15 のキーのヘルプと同じ）。
    private static func button(for key: Key) -> Buttons? {
        switch key {
        case .left: .left
        case .right: .right
        case .up: .up
        case .down: .down
        case .z, .space: .jump
        case .x: .fire
        case .q, .t, .d, .interrupt: nil
        }
    }

    /// スクリーンセーバーのキー。押したとき（簡易な方式では届いたとき）だけ効く。
    private static func command(_ event: KeyEvent) -> Command? {
        switch event {
        case .pressed(let key), .typed(let key):
            switch key {
            case .q, .interrupt: return .quit
            case .t: return .cycleTheme
            case .d: return .cycleDifficulty
            case .left, .right, .up, .down, .z, .x, .space: return nil
            }
        case .released:
            return nil
        }
    }
}

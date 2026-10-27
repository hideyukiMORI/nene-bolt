/// いま押されているキー（FR-04b・ADR 0007）。キーの出来事と時刻（ミリ秒・合成ルートが測って渡す）から決める。
///
/// - 押す・離すを受け取る方式: 押してから離すまで。離したことが届かなくても（窓の外へ注意が移った等）、
///   押しっぱなしのくり返しが `releaseTimeout` 届かなければ離したとみなす
/// - 簡易な方式: 文字が届いてから、最初は `firstRepeat`（端末のくり返しが始まるまで）、くり返しが始まったら `repeatGap` の間
///
/// 1 刻みの間に押して離した短い打鍵も取りこぼさないよう、押したキーは次に `take` するまで残す。
public struct HeldKeys: Sendable {
    /// 押す・離すの方式で、くり返しが途絶えたら離したとみなす時間（ミリ秒）。
    public static let releaseTimeout = 1_000
    /// 簡易な方式で、最初の 1 文字を押しているとみなす時間（ミリ秒。端末のくり返しの始まりより少し長く）。
    public static let firstRepeat = 600
    /// 簡易な方式で、くり返しの 1 文字を押しているとみなす時間（ミリ秒）。
    public static let repeatGap = 120

    private struct Entry: Sendable {
        var lastSeen: Int
        var repeating: Bool
        var releasable: Bool
    }

    private var entries: [Key: Entry] = [:]
    private var latched: [Key] = []

    /// 空の組。
    public init() {}

    /// 出来事を 1 つ反映する。
    public mutating func apply(_ event: KeyEvent, at now: Int) {
        let key = event.key
        switch event {
        case .pressed:
            entries[key] = Entry(lastSeen: now, repeating: false, releasable: true)
            latched.append(key)
        case .released:
            entries[key] = nil
        case .typed:
            let repeating = entries[key].map { now - $0.lastSeen <= Self.firstRepeat + Self.repeatGap } ?? false
            entries[key] = Entry(lastSeen: now, repeating: repeating, releasable: false)
            latched.append(key)
        }
    }

    /// いま押されているキー（前回の `take` から後に押したキーを含む）。取り出すと、押した記録は消える。
    public mutating func take(at now: Int) -> [Key] {
        let held = Key.allCases.filter { key in
            guard let entry = entries[key] else {
                return false
            }
            let window = entry.releasable ? Self.releaseTimeout : (entry.repeating ? Self.repeatGap : Self.firstRepeat)
            return now - entry.lastSeen < window
        }
        let pressed = latched
        latched = []
        return Key.allCases.filter { held.contains($0) || pressed.contains($0) }
    }
}

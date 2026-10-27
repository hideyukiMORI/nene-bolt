/// 1 刻みに押されているボタンの組（ADR 0005）。人のキーも AI の判断も、この型で Core に渡る（ARC-001）。
public struct Buttons: OptionSet, Sendable, Hashable {
    public let rawValue: UInt8

    /// 組を作る。
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let left = Buttons(rawValue: 1 << 0)
    public static let right = Buttons(rawValue: 1 << 1)
    public static let up = Buttons(rawValue: 1 << 2)
    public static let down = Buttons(rawValue: 1 << 3)
    public static let jump = Buttons(rawValue: 1 << 4)
    public static let fire = Buttons(rawValue: 1 << 5)

    /// 何も押していない。
    public static let none: Buttons = []
}

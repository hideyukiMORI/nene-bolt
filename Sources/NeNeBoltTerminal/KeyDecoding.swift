/// キー入力のバイト列を読んだ結果。
public struct KeyDecoding: Sendable, Hashable {
    /// 読み取った出来事（届いた順）。
    public let events: [KeyEvent]
    /// 押す・離すを受け取る方式の列が 1 つでもあったか（端末がその方式に応じた証拠）。
    public let reportsReleases: Bool
}

/// キー入力がどちらの方式で届いているか（FR-04b）。決めるのは合成ルートで、Render は HUD に出すだけ。
public enum KeyReading: Sendable, Hashable {
    /// まだキーが届いていない（どちらの方式か分からない）。
    case unknown
    /// 押す・離すの両方が届く。
    case pressAndRelease
    /// 文字とキーのくり返しだけが届く（離したことは推し量る）。
    case repeatOnly
}

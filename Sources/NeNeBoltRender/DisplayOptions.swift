/// 見た目の選択（テーマ）と端末の性質。持ち主は合成ルートで、Render は受け取って描くだけ。
public struct DisplayOptions: Sendable, Hashable {
    public let theme: Theme
    public let traits: TerminalTraits

    /// 組を作る。
    public init(theme: Theme, traits: TerminalTraits) {
        self.theme = theme
        self.traits = traits
    }

    /// テーマを次へ替えた組（`t`）。
    public var cyclingTheme: DisplayOptions {
        DisplayOptions(theme: theme.next, traits: traits)
    }
}

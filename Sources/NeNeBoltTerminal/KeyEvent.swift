/// キー入力から読み取った 1 つの出来事。
public enum KeyEvent: Sendable, Hashable {
    /// 押した（押す・離すを受け取る方式。押しっぱなしの間はくり返し届く）。
    case pressed(Key)
    /// 離した（押す・離すを受け取る方式）。
    case released(Key)
    /// 文字として届いた（簡易な方式。離したことは届かず、押しっぱなしはキーのくり返しで届く）。
    case typed(Key)

    /// どのキーの出来事か。
    public var key: Key {
        switch self {
        case .pressed(let key), .released(let key), .typed(let key): key
        }
    }
}

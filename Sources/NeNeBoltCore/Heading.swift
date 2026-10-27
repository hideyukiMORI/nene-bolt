/// 左右の向き。
public enum Heading: Sendable, Hashable {
    case left
    case right

    /// 横の符号（-1 か 1）。
    public var sign: Int {
        switch self {
        case .left: -1
        case .right: 1
        }
    }

    /// 逆向き。
    public var reversed: Heading {
        switch self {
        case .left: .right
        case .right: .left
        }
    }
}

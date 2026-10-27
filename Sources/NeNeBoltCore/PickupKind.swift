/// 拾うものの種類（FR-02e）。
public enum PickupKind: Sendable, Hashable, CaseIterable {
    case coin
    case health
    case oneUp
    case powerUp

    /// 拾ったときの得点。
    public var points: Int {
        switch self {
        case .coin: 10
        case .health: 50
        case .oneUp: 500
        case .powerUp: 300
        }
    }
}

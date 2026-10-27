/// 場面を 1 刻み進めた結果。
public struct SessionStep: Sendable, Hashable {
    /// 次のセッション。
    public let session: Session
    /// 起きたこと（起きた順）。
    public let events: [SessionEvent]
}

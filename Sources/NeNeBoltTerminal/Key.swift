/// 端末から読み取れるキー（閉じた集合）。どのキーが何の操作かは合成ルートが決める（ADR 0004・ADR 0007）。
public enum Key: Sendable, Hashable, CaseIterable {
    case left
    case right
    case up
    case down
    case z
    case x
    case space
    case q
    case t
    case d
    /// Ctrl+C。押す・離すを受け取る方式では SIGINT ではなくキーとして届く。
    case interrupt
}

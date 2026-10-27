/// ボスの段階。
public enum BossState: Sendable, Hashable {
    /// まだ部屋に入っていない（ボスの居ない面もこれのまま）。
    case waiting
    /// 戦っている。
    case fighting(Boss)
    /// 倒した。
    case defeated
}

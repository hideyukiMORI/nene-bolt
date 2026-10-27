/// 誰が自機を操作しているか（FR-04a）。決めるのは合成ルートで、Render は HUD に出すだけ。
public enum PilotLabel: Sendable, Hashable {
    /// AI のランナー（名前）。
    case autopilot(name: String)
    /// 人。AI に戻るまでの残りの秒。
    case player(secondsLeft: Int)
}

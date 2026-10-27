/// 消える足場の時刻表（FR-02b・ADR 0005）。面の始まりからの刻みで決まり、乱数を使わない（覚えて渡るもの）。
///
/// 1 周は `period` 刻み。組 g は `g × stagger` 刻み遅れて現れ、`visibleTicks` 刻み見えて消える。だから 0 → 1 → 2 → 3 の順に現れる。
public enum VanishingClock {
    /// 1 周の刻みの数（30 刻み／秒で 4 秒）。
    public static let period = 120
    /// 1 つの組が見えている刻みの数。
    public static let visibleTicks = 54
    /// 組ごとの遅れ（刻み）。
    public static let stagger = 30

    /// 面の始まりから `tick` 刻みのときに、組が見えているか。
    public static func isVisible(group: Int, at tick: Int) -> Bool {
        let phase = ((tick - group * stagger) % period + period) % period
        return phase < visibleTicks
    }
}

/// 1 刻みに進む量（単位）。Core は秒を知らないので、速さはいつも「1 刻みあたり」で書く。
public struct Velocity: Sendable, Hashable {
    /// 横の量。
    public let dx: Int
    /// 縦の量（正なら下へ）。
    public let dy: Int

    /// 速さを作る。
    public init(dx: Int, dy: Int) {
        self.dx = dx
        self.dy = dy
    }

    /// 止まっている速さ。
    public static let zero = Velocity(dx: 0, dy: 0)
}

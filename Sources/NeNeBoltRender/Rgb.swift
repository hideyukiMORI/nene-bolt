/// 24 ビットの色。画面の色の値を決めるのは `Theme` だけ（Render の配色表）。
public struct Rgb: Sendable, Hashable {
    public let red: UInt8
    public let green: UInt8
    public let blue: UInt8

    /// 色を作る。どの組み合わせも正しい色なので検証は要らない（256 色への近似を Terminal とそのテストで扱うために公開する）。
    public init(red: UInt8, green: UInt8, blue: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
    }

    /// 2 つの色を混ぜる（`percent` は 2 つ目の色の割合）。
    static func mix(_ first: Rgb, _ second: Rgb, percent: Int) -> Rgb {
        func channel(_ a: UInt8, _ b: UInt8) -> UInt8 {
            UInt8((Int(a) * (100 - percent) + Int(b) * percent) / 100)
        }
        return Rgb(
            red: channel(first.red, second.red), green: channel(first.green, second.green),
            blue: channel(first.blue, second.blue))
    }
}

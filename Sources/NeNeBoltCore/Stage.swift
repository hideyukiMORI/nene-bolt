/// 面（1〜4）。
public struct Stage: Sendable, Hashable {
    /// 番号。
    public let number: Int

    /// 番号から面を作る。
    public init(number: Int) {
        precondition((1...StageCatalog.count).contains(number), "面は 1〜4")
        self.number = number
    }

    /// 種類。
    public var kind: StageKind {
        StageKind.allCases[number - 1]
    }

    /// 次の面。最後の面なら nil。
    public var next: Stage? {
        number < StageCatalog.count ? Stage(number: number + 1) : nil
    }
}

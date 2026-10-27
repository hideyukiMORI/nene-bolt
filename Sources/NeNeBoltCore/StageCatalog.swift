/// 4 つの面（FR-02a・ADR 0005）。地図は `StageCatalog+*.swift` に 1 面ずつある。
public enum StageCatalog {
    /// 面の数。
    public static let count = 4

    /// 面（1 から）の地図。地図は製品に埋め込んだ決まったもので、読めなければプログラムの欠陥（テストで全部を読む）。
    public static func map(of stage: Stage) -> StageMap {
        switch StageMap.decode(pages(of: stage)) {
        case .decoded(let map): return map
        case .rejected(let reason): preconditionFailure("面 \(stage.number) の地図が読めない: \(reason)")
        }
    }

    static func pages(of stage: Stage) -> [[String]] {
        switch stage.kind {
        case .grassland: grassland
        case .cavern: cavern
        case .sky: sky
        case .fortress: fortress
        }
    }
}

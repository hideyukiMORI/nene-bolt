/// 地図を読んだ結果。
public enum StageMapDecodeOutcome: Sendable, Hashable {
    case decoded(StageMap)
    case rejected(StageMapRejection)
}

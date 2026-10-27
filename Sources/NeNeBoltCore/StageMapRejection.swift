/// 地図が読めなかった理由。
public enum StageMapRejection: Sendable, Hashable {
    /// 頁の行の長さがそろっていない（頁・行）。
    case ragged(page: Int, row: Int)
    /// 知らない文字（文字・列・段）。
    case unknownCharacter(Character, column: Int, row: Int)
    /// 始まりの位置が 1 つでない（見つかった数）。
    case starts(Int)
    /// 頁の行の数がそろっていない。
    case uneven
}

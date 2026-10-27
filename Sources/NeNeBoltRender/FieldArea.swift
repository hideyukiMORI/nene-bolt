/// 面の窓の中の矩形（桁と行は窓の左上が 0・端末の桁と行の数）。
struct FieldArea: Sendable, Hashable {
    let column: Int
    let row: Int
    let width: Int
    let height: Int
}

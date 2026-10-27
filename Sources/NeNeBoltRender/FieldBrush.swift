/// 面の窓の中だけを塗る筆。窓の外へはみ出す分は捨てる（枠と HUD を汚さない）。
struct FieldBrush: Sendable {
    let layout: ScreenLayout

    /// 面の窓の中の矩形を塗る（桁と行は窓の左上が 0）。
    func paint(_ area: FieldArea, color: Rgb, into grid: inout Grid) {
        let first = max(area.column, 0)
        let last = min(area.column + area.width, layout.fieldWidth)
        let top = max(area.row, 0)
        let bottom = min(area.row + area.height, layout.fieldHeight)
        guard first < last, top < bottom else {
            return
        }
        for line in top..<bottom {
            grid.paint(
                column: layout.fieldColumn + first, row: layout.fieldRow + line, width: last - first, color: color)
        }
    }

    /// 面の窓の中に文字を書く（地の色の上）。
    func write(_ text: String, at spot: (column: Int, row: Int), colors: CellColors, into grid: inout Grid) {
        let (column, row) = spot
        guard (0..<layout.fieldHeight).contains(row) else {
            return
        }
        for (offset, character) in text.enumerated() where (0..<layout.fieldWidth).contains(column + offset) {
            grid.write(
                String(character), column: layout.fieldColumn + column + offset, row: layout.fieldRow + row,
                colors: colors)
        }
    }

    /// 窓の中のその桁と行のセル。
    func cell(_ grid: Grid, column: Int, row: Int) -> Cell {
        grid[layout.fieldColumn + column, layout.fieldRow + row]
    }
}

/// 1 画面分の文字セルの格子。Render が作り、Terminal が前の格子との差分を書く。
public struct Grid: Sendable, Hashable {
    public let size: ScreenSize
    /// 格納が private なので、合成される memberwise init も private になる（外から格子を作る経路は `filled` だけ）。
    private var cells: [Cell]

    /// 全面を 1 つのセルで埋めた格子。
    static func filled(_ size: ScreenSize, with cell: Cell) -> Grid {
        Grid(size: size, cells: Array(repeating: cell, count: size.columns * size.rows))
    }

    /// その位置のセル。格子の外を読むのはプログラムの欠陥。
    public subscript(column: Int, row: Int) -> Cell {
        precondition((0..<size.columns).contains(column) && (0..<size.rows).contains(row), "格子の外")
        return cells[row * size.columns + column]
    }

    /// 文字列を左から 1 文字 1 桁で書く。格子からはみ出す分は捨てる。
    mutating func write(_ text: String, column: Int, row: Int, colors: CellColors) {
        guard (0..<size.rows).contains(row) else {
            return
        }
        for (offset, character) in text.enumerated() where (0..<size.columns).contains(column + offset) {
            cells[row * size.columns + column + offset] = Cell(
                character: character, foreground: colors.foreground, background: colors.background)
        }
    }

    /// 色の付いた切れを左から続けて書き、書いた桁数を返す。
    @discardableResult
    mutating func write(_ segments: [Segment], column: Int, row: Int, background: Rgb) -> Int {
        var offset = 0
        for segment in segments {
            write(
                segment.text, column: column + offset, row: row,
                colors: CellColors(foreground: segment.color, background: background))
            offset += segment.text.count
        }
        return offset
    }

    /// 空白で塗る（自機・敵・弾・トーチカ・爆発のセルと、帯の地）。
    mutating func paint(column: Int, row: Int, width: Int, color: Rgb) {
        write(
            String(repeating: " ", count: width), column: column, row: row,
            colors: CellColors(foreground: color, background: color))
    }
}

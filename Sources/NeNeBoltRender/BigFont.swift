/// 帯の大きな文字（3 × 5 の点・FR-02h）。点は空白のセルを塗って描き、文字は書かない。
enum BigFont {
    /// 1 文字の幅（点）と、文字の間（点）。
    static let width = 3
    static let gap = 1
    /// 高さ（点）。
    static let height = 5

    /// 文字列の点の並び（行ごとの、塗る桁の列）。知らない文字は空白。
    static func pixels(_ text: String) -> [[Bool]] {
        let glyphs = text.uppercased().map { glyph($0) }
        return (0..<height).map { row in
            glyphs.enumerated().flatMap { index, rows in
                let bits = rows[row]
                let cells = (0..<width).map { bits >> (width - 1 - $0) & 1 == 1 }
                return index == glyphs.count - 1 ? cells : cells + [false]
            }
        }
    }

    /// 文字列の幅（点）。
    static func span(_ text: String) -> Int {
        text.isEmpty ? 0 : text.count * (width + gap) - gap
    }

    /// 1 文字の 5 行（各行は 3 ビット・左が上位）。
    private static func glyph(_ character: Character) -> [Int] {
        table[character] ?? [0, 0, 0, 0, 0]
    }

    private static let table: [Character: [Int]] = [
        "A": [2, 5, 7, 5, 5], "B": [6, 5, 6, 5, 6], "C": [3, 4, 4, 4, 3], "D": [6, 5, 5, 5, 6], "E": [7, 4, 6, 4, 7],
        "F": [7, 4, 6, 4, 4], "G": [3, 4, 5, 5, 3], "H": [5, 5, 7, 5, 5], "I": [7, 2, 2, 2, 7], "J": [1, 1, 1, 5, 2],
        "K": [5, 5, 6, 5, 5], "L": [4, 4, 4, 4, 7], "M": [5, 7, 7, 5, 5], "N": [6, 5, 5, 5, 5], "O": [2, 5, 5, 5, 2],
        "P": [6, 5, 6, 4, 4], "Q": [2, 5, 5, 6, 3], "R": [6, 5, 6, 5, 5], "S": [3, 4, 2, 1, 6], "T": [7, 2, 2, 2, 2],
        "U": [5, 5, 5, 5, 7], "V": [5, 5, 5, 5, 2], "W": [5, 5, 7, 7, 5], "X": [5, 5, 2, 5, 5], "Y": [5, 5, 2, 2, 2],
        "Z": [7, 1, 2, 4, 7], "0": [7, 5, 5, 5, 7], "1": [2, 6, 2, 2, 7], "2": [6, 1, 2, 4, 7], "3": [6, 1, 2, 1, 6],
        "4": [5, 5, 7, 1, 1], "5": [7, 4, 6, 1, 6], "6": [3, 4, 7, 5, 7], "7": [7, 1, 1, 2, 2], "8": [7, 5, 7, 5, 7],
        "9": [7, 5, 7, 1, 6], "!": [2, 2, 2, 0, 2], " ": [0, 0, 0, 0, 0],
    ]
}

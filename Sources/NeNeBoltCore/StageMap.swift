/// 1 つの面の地形と物の並び（ADR 0005）。地図は文字の行で書き、90 桁ずつの頁を左から並べる（行の長さの上限に収めるため）。
///
/// 地形の文字: 空白＝空き・`#` 固い・`=` 滑る・`H` 梯子・`^` 棘・`1`〜`4` 消える足場の組・`<` `>` コンベア。それ以外の文字は物（`SpawnKind`）。
/// 面の外は、左右と上は固い壁、下は穴（何も無い）として読む。
public struct StageMap: Sendable, Hashable {
    /// 幅（セル）。
    public let columns: Int
    /// 高さ（セル）。
    public let rows: Int
    /// 物（上の段・左の列から）。
    public let spawns: [Spawn]
    private let cells: [Terrain]

    private init(columns: Int, rows: Int, cells: [Terrain], spawns: [Spawn]) {
        self.columns = columns
        self.rows = rows
        self.cells = cells
        self.spawns = spawns
    }

    /// セルの地形。面の外は、下は空き（穴）、それ以外は固い。
    public subscript(column: Int, row: Int) -> Terrain {
        guard row < rows else {
            return .empty
        }
        guard column >= 0, column < columns, row >= 0 else {
            return .solid
        }
        return cells[row * columns + column]
    }

    /// 幅（単位）。
    public var width: Int { Field.units(columns) }
    /// 高さ（単位）。
    public var height: Int { Field.units(rows) }

    /// 種類の物の最初のもの。
    public func first(_ kind: SpawnKind) -> Spawn? {
        spawns.first { $0.kind == kind }
    }

    /// 頁を読む。
    public static func decode(_ pages: [[String]]) -> StageMapDecodeOutcome {
        guard let height = pages.first?.count, pages.allSatisfy({ $0.count == height }) else {
            return .rejected(.uneven)
        }
        var lines = Array(repeating: "", count: height)
        for (index, page) in pages.enumerated() {
            guard let width = page.first?.count, page.allSatisfy({ $0.count == width }) else {
                return .rejected(.ragged(page: index, row: page.firstIndex { $0.count != page.first?.count } ?? 0))
            }
            for row in 0..<height {
                lines[row] += page[row]
            }
        }
        return read(lines)
    }

    private static func read(_ lines: [String]) -> StageMapDecodeOutcome {
        let columns = lines.first?.count ?? 0
        var cells: [Terrain] = []
        var spawns: [Spawn] = []
        for (row, line) in lines.enumerated() {
            for (column, character) in line.enumerated() {
                if let terrain = terrain(character) {
                    cells.append(terrain)
                } else if let kind = SpawnKind.of(character) {
                    cells.append(.empty)
                    spawns.append(Spawn(kind: kind, column: column, row: row))
                } else {
                    return .rejected(.unknownCharacter(character, column: column, row: row))
                }
            }
        }
        let starts = spawns.filter { $0.kind == .start }.count
        guard starts == 1 else {
            return .rejected(.starts(starts))
        }
        return .decoded(StageMap(columns: columns, rows: lines.count, cells: cells, spawns: spawns))
    }

    private static func terrain(_ character: Character) -> Terrain? {
        if let digit = character.wholeNumberValue, (1...4).contains(digit) {
            return .vanishing(group: digit - 1)
        }
        return symbols[character]
    }

    private static let symbols: [Character: Terrain] = [
        " ": .empty, "#": .solid, "=": .ice, "H": .ladder, "^": .spike, "<": .conveyor(.left), ">": .conveyor(.right),
    ]
}

import NeNeBoltCore

/// 道のりの地図の元になる、立てる所のつながり（ADR 0008）。点は「立てるセル」の番号（行 × 列数 ＋ 列）。
/// 動く足場は、往復する範囲のセルをどれも乗れるとみなす（いつかはそこへ来る）。
struct Graph {
    let map: StageMap
    private let rides: Set<Int>

    init(game: Game) {
        map = game.map
        var rides: Set<Int> = []
        for platform in game.platforms {
            let row = Field.cell(platform.position.y)
            for column in Field.cell(platform.minX)...Field.cell(platform.maxX + Platform.width - 1) {
                rides.insert(row * game.map.columns + column)
            }
        }
        self.rides = rides
    }

    /// 跳んで届く横の距離（セル）と、上がれる段の数。
    static let jumpReach = 3
    static let jumpRise = 3
    /// 落ちるとき、何段下まで見るか。
    static let fallDepth = 12

    /// 立てるか（体の 2 セルが通れて、足もとが乗れるか、梯子をつかめる）。
    func isNode(_ column: Int, _ row: Int) -> Bool {
        guard (0..<map.columns).contains(column), (1..<map.rows).contains(row),
            open(map[column, row]), open(map[column, row - 1])
        else {
            return false
        }
        if case .ladder = map[column, row] {
            return true
        }
        return row + 1 < map.rows && (support(map[column, row + 1]) || rides.contains((row + 1) * map.columns + column))
    }

    /// そのセルか、真下の最初の立てるセル（行き先の印が宙にあっても点にする）。
    func landing(column: Int, row: Int) -> Int? {
        guard row < map.rows else {
            return nil
        }
        for below in max(row, 1)..<map.rows where isNode(column, below) {
            return below * map.columns + column
        }
        return nil
    }

    /// 点ごとの「その点へ来られる点と重み」。
    func reversedEdges() -> [[(Int, Int)]] {
        var reversed = Array(repeating: [(Int, Int)](), count: map.columns * map.rows)
        for row in 1..<map.rows {
            for column in 0..<map.columns where isNode(column, row) {
                let from = row * map.columns + column
                for (to, cost) in edges(column, row) {
                    reversed[to].append((from, cost))
                }
            }
        }
        return reversed
    }

    /// 点から行ける点と重み（歩く 1・梯子 1・跳ぶと落ちるは横と縦の距離の和 ＋ 1）。同じ高さへは横 4 セル（3 セルの穴）まで跳べる。
    private func edges(_ column: Int, _ row: Int) -> [(Int, Int)] {
        var result: [(Int, Int)] = []
        func add(_ c: Int, _ r: Int, _ cost: Int) {
            if isNode(c, r) {
                result.append((r * map.columns + c, cost))
            }
        }
        add(column - 1, row, 1)
        add(column + 1, row, 1)
        if case .ladder = map[column, row] {
            add(column, row - 1, 1)
        }
        if case .ladder = map[column, row + 1] {
            add(column, row + 1, 1)
        }
        for dx in -(Graph.jumpReach + 1)...(Graph.jumpReach + 1) where abs(dx) >= 2 {
            add(column + dx, row, abs(dx) + 1)
        }
        for rise in 1...Graph.jumpRise {
            // 2 段までなら、同じ高さと同じく 4 セル先まで届く（跳ぶ高さに余裕がある）
            let reach = rise <= 2 ? Graph.jumpReach + 1 : Graph.jumpReach
            for dx in -reach...reach {
                add(column + dx, row - rise, abs(dx) + rise + 1)
            }
        }
        for dx in -(Graph.jumpReach + 2)...(Graph.jumpReach + 2) where dx != 0 {
            for drop in 1...Graph.fallDepth where abs(dx) <= Graph.jumpReach + 1 + drop / 2 {
                add(column + dx, row + drop, abs(dx) + drop + 1)
            }
        }
        return result
    }

    /// 体が通れるセル（固い地形と棘は通れない。消える足場は通れるとみなす）。
    private func open(_ terrain: Terrain) -> Bool {
        switch terrain {
        case .empty, .ladder, .vanishing: true
        case .solid, .ice, .conveyor, .spike: false
        }
    }

    /// 乗れるセル（消える足場は、いつかは乗れるので乗れるとみなす）。
    private func support(_ terrain: Terrain) -> Bool {
        switch terrain {
        case .solid, .ice, .conveyor, .vanishing, .ladder: true
        case .empty, .spike: false
        }
    }
}

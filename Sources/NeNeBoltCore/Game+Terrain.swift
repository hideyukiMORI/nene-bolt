/// 地形との当たり（ADR 0005）。「固いか」の判定はここの 1 経路だけ。
extension Game {
    /// そのセルの地形（ボスの部屋の扉が閉じていれば、扉のセルは固い）。
    public func terrain(column: Int, row: Int) -> Terrain {
        if doorClosed, map.spawns.contains(where: { $0.kind == .door && $0.column == column && $0.row == row }) {
            return .solid
        }
        return map[column, row]
    }

    /// その地形が、いま横からも下からも固いか（消える足場は見えている間だけ）。
    func isSolid(_ terrain: Terrain) -> Bool {
        switch terrain {
        case .solid, .ice, .conveyor: true
        case .vanishing(let group): VanishingClock.isVisible(group: group, at: stageTick)
        case .empty, .ladder, .spike: false
        }
    }

    /// 箱が重なるセルの範囲（列と段）。
    static func cells(of box: Box) -> (columns: ClosedRange<Int>, rows: ClosedRange<Int>) {
        (Field.cell(box.origin.x)...Field.cell(box.right - 1), Field.cell(box.origin.y)...Field.cell(box.bottom - 1))
    }

    /// 箱が固い地形にぶつかるか。`before` で既に重なっていたセルは数えない（現れた消える足場に閉じ込めない）。
    /// 下へ動くときは、梯子のいちばん上の段も上から乗れる床として数える。
    func collides(_ box: Box, before: Box, movingDown: Bool) -> Bool {
        let (columns, rows) = Game.cells(of: box)
        let (oldColumns, oldRows) = Game.cells(of: before)
        for row in rows {
            for column in columns where !(oldColumns.contains(column) && oldRows.contains(row)) {
                let ground = terrain(column: column, row: row)
                if isSolid(ground) {
                    return true
                }
                if movingDown, isLadderTop(column: column, row: row), before.bottom <= Field.units(row) {
                    return true
                }
            }
        }
        return false
    }

    /// 梯子のいちばん上の段か（上のセルが梯子でない梯子）。
    func isLadderTop(column: Int, row: Int) -> Bool {
        guard case .ladder = map[column, row] else {
            return false
        }
        if case .ladder = map[column, row - 1] {
            return false
        }
        return true
    }

    /// 箱が棘に触れているか。
    func touchesSpike(_ box: Box) -> Bool {
        let (columns, rows) = Game.cells(of: box)
        for row in rows {
            for column in columns {
                if case .spike = map[column, row] {
                    return true
                }
            }
        }
        return false
    }

    /// 箱の真ん中の列に梯子があるか（つかまれるか）。
    func ladderColumn(for box: Box) -> Int? {
        let column = Field.cell(box.centerX)
        let (_, rows) = Game.cells(of: box)
        for row in rows {
            if case .ladder = map[column, row] {
                return column
            }
        }
        return nil
    }

    /// 足の下の地形（立っている床の種類）。
    func footing(of box: Box) -> Terrain {
        let row = Field.cell(box.bottom)
        let (columns, _) = Game.cells(of: box)
        for column in columns {
            let ground = terrain(column: column, row: row)
            if isSolid(ground) {
                return ground
            }
        }
        return .empty
    }
}

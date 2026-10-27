import NeNeBoltCore

/// 面のどこを映すか（ADR 0007）。Core の座標（単位）を面の窓の桁と行に直すのはこの型の 1 経路だけ。
///
/// 自機を窓の左から 2/5 の所に置き（前を広く見せる）、面の端では止める。縦は自機を真ん中に置き、面の上下の端で止める。
/// 横は半セル（8 単位＝端末の 1 桁）、縦は 1 セル（16 単位＝端末の 1 行）に合わせるので、地形のセルが行と桁からずれない。
/// 状態を持たず、ゲームの状態と配置だけから決まる（決定性のテストが見た目の変更で壊れない・ADR 0004）。
struct Camera: Sendable, Hashable {
    /// 窓の左端と上端（単位）。
    let left: Int
    let top: Int
    /// 窓の幅と高さ（セル）。
    let columns: Int
    let rows: Int

    /// 端末の 1 桁の単位数。
    static let unitsPerColumn = Field.cellUnits / 2

    /// ゲームの状態から決める。
    static func following(_ game: Game, layout: ScreenLayout) -> Camera {
        framing(game.runner.box, map: (game.map.width, game.map.height), layout: layout)
    }

    /// 自機の箱と面の大きさ（単位）から決める。
    static func framing(_ box: Box, map: (width: Int, height: Int), layout: ScreenLayout) -> Camera {
        let width = Field.units(layout.viewColumns)
        let height = Field.units(layout.viewRows)
        let wantedLeft = box.centerX - width * 2 / 5
        let wantedTop = box.centerY - height / 2
        let left = min(max(wantedLeft, 0), max(map.width - width, 0))
        let top = min(max(wantedTop, 0), max(map.height - height, 0))
        return Camera(
            left: (left >> 3) << 3, top: Field.units(Field.cell(top)), columns: layout.viewColumns,
            rows: layout.viewRows)
    }

    /// 横の位置の、面の窓の中の桁（負の無限大へ丸める）。
    func column(_ x: Int) -> Int {
        (x - left) >> 3
    }

    /// 縦の位置の、面の窓の中の行。
    func row(_ y: Int) -> Int {
        Field.cell(y - top)
    }

    /// 窓に映るセルの範囲（列と段・端が少しはみ出してよい）。
    var visibleCells: (columns: ClosedRange<Int>, rows: ClosedRange<Int>) {
        let firstColumn = Field.cell(left)
        let firstRow = Field.cell(top)
        return (firstColumn...(firstColumn + columns), firstRow...(firstRow + rows - 1))
    }
}

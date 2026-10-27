import NeNeBoltCore

/// 面の窓の背景（FR-02h・ADR 0010）。地の色で消し、遠くと近くの 2 層の点をカメラより遅く流す（多層の背景のスクロール）。
///
/// 点の置き場所は、層の中の位置の番号から決める（乱数を読まない・ARC-007）。点は ASCII の 1 文字で、地の上にだけ置く。
/// ボスの閃光の間は、窓の地が火花の色を帯びる（文字を書かないセルだけ）。
struct Backdrop {
    let theme: Theme
    let palette: StagePalette
    let camera: Camera
    let brush: FieldBrush

    /// 遠くの層はカメラの 1/4、近くの層は 1/2 の速さで流れる。
    static let farDivisor = 4
    static let nearDivisor = 2

    /// 窓を消して、背景の点を置く。
    func draw(stage: StageKind, flashing: Bool, into grid: inout Grid) {
        let ground = flashing ? Rgb.mix(theme.ground, theme.spark, percent: 35) : theme.ground
        let layout = brush.layout
        brush.paint(
            FieldArea(column: 0, row: 0, width: layout.fieldWidth, height: layout.fieldHeight), color: ground,
            into: &grid)
        guard !flashing else {
            return
        }
        let far = CellColors(foreground: palette.far, background: ground)
        let near = CellColors(foreground: palette.near, background: ground)
        layer(BackdropLayer(divisor: Backdrop.farDivisor, glyph: ".", salt: 7), colors: far, into: &grid)
        layer(
            BackdropLayer(divisor: Backdrop.nearDivisor, glyph: Backdrop.glyph(stage), salt: 3), colors: near,
            into: &grid)
    }

    /// 1 つの層。窓の桁と行ごとに、層の中の位置の番号から点を置くか決める。
    private func layer(_ spec: BackdropLayer, colors: CellColors, into grid: inout Grid) {
        let (divisor, glyph, salt) = (spec.divisor, spec.glyph, spec.salt)
        let layout = brush.layout
        let shift = camera.left / divisor / Camera.unitsPerColumn
        let lift = camera.top / divisor / Field.cellUnits
        for row in 0..<layout.fieldHeight {
            for column in 0..<layout.fieldWidth {
                guard Backdrop.scatter(column + shift, row + lift, salt: salt) else {
                    continue
                }
                brush.write(glyph, at: (column, row), colors: colors, into: &grid)
            }
        }
    }

    /// 層の中の位置に点を置くか（およそ 40 か所に 1 か所。番号をかき混ぜて、縞に並ばないようにする）。
    static func scatter(_ x: Int, _ y: Int, salt: Int) -> Bool {
        var hash = UInt32(truncatingIfNeeded: x) &* 0x9E37_79B1 ^ UInt32(truncatingIfNeeded: y &+ salt) &* 0x85EB_CA77
        hash ^= hash >> 13
        hash = hash &* 0xC2B2_AE35
        hash ^= hash >> 16
        return hash % 41 == 0
    }

    /// 近くの層の字（面ごと）。
    private static func glyph(_ stage: StageKind) -> String {
        switch stage {
        case .grassland: "'"
        case .cavern: "*"
        case .sky: "~"
        case .fortress: "|"
        }
    }
}

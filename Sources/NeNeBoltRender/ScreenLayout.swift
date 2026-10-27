/// 80 × 24 に入る配置（FR-16）。
///
/// 上端に題の帯、その下に罫線の枠の中の面の窓（39 セル × 17 段＝端末の 78 桁 × 17 行・1 セル＝2 桁）、
/// 枠の下に 2 行の HUD と 1 行の COMMS、下端にキーの帯（ADR 0007・ADR 0009）。横スクロールなので、面の窓を端末の幅いっぱいに取る。
enum ScreenLayout {
    /// 面の窓の幅と高さ（セル）。
    static let viewColumns = 39
    static let viewRows = 17
    /// 面の窓の左上の端末の桁と行。
    static let fieldColumn = 1
    static let fieldRow = 2
    /// 面の窓の幅と高さ（端末の桁と行）。
    static let fieldWidth = viewColumns * 2
    static let fieldHeight = viewRows
    /// 枠の上端と下端の行。
    static let frameTop = fieldRow - 1
    static let frameBottom = fieldRow + fieldHeight
    /// HUD の最初の行と行数。
    static let hudRow = frameBottom + 1
    static let hudRows = 2
    /// COMMS（ランナーのセリフ）の行。
    static let commsRow = hudRow + hudRows
    /// キーの帯の行。
    static let footerRow = commsRow + 1
    /// この配置がちょうど入る大きさ。
    static let size = ScreenSize(columns: fieldWidth + 2, rows: footerRow + 1)
}

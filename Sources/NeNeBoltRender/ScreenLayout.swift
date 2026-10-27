/// 画面の配置（FR-16・ADR 0007・ADR 0009・ADR 0010）。80 × 24 に入る配置と、100 × 26 以上の広い配置の 2 つ。
///
/// 上端に題の帯、その下に罫線の枠の中の面の窓（1 セル＝2 桁）、枠の下に 2 行の HUD と COMMS、下端にキーの帯。
/// 横スクロールなので、面の窓を端末の幅いっぱいに取る。
struct ScreenLayout: Sendable, Hashable {
    /// 面の窓の幅と高さ（セル）。
    let viewColumns: Int
    let viewRows: Int
    /// COMMS の行数。
    let commsRows: Int

    /// 80 × 24: 窓は 39 セル × 17 段、COMMS は 1 行。
    static let compact = ScreenLayout(viewColumns: 39, viewRows: 17, commsRows: 1)
    /// 100 × 26 以上: 窓は 49 セル × 18 段、COMMS は直近の 2 行。
    static let large = ScreenLayout(viewColumns: 49, viewRows: 18, commsRows: 2)

    /// 面の窓の左上の端末の桁と行。
    var fieldColumn: Int { 1 }
    var fieldRow: Int { 2 }
    /// 面の窓の幅と高さ（端末の桁と行）。
    var fieldWidth: Int { viewColumns * 2 }
    var fieldHeight: Int { viewRows }
    /// 枠の上端と下端の行。
    var frameTop: Int { fieldRow - 1 }
    var frameBottom: Int { fieldRow + fieldHeight }
    /// HUD の最初の行と行数。
    var hudRow: Int { frameBottom + 1 }
    var hudRows: Int { 2 }
    /// COMMS の最初の行。
    var commsRow: Int { hudRow + hudRows }
    /// キーの帯の行。
    var footerRow: Int { commsRow + commsRows }
    /// この配置がちょうど入る大きさ。
    var size: ScreenSize { ScreenSize(columns: fieldWidth + 2, rows: footerRow + 1) }
}

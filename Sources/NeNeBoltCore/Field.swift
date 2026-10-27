/// 固定小数点の座標の単位（ADR 0005）。座標は整数で持ち、1 セルを `cellUnits` に割る。y は下向き。
///
/// セルへの変換は `cell(_:)` の 1 経路だけ（負の数でも負の無限大へ丸める・ADR 0001 の X-l）。面の広さは面ごとに違う（`StageMap`）。
public enum Field {
    /// 1 セルの単位数の 2 の冪の指数。
    public static let cellShift = 4
    /// 1 セルの単位数。
    public static let cellUnits = 1 << cellShift

    /// 単位の座標をセルの番号に直す（負の無限大へ丸める）。
    public static func cell(_ units: Int) -> Int {
        units >> cellShift
    }

    /// セルの番号をそのセルの左端（上端）の単位に直す。
    public static func units(_ cell: Int) -> Int {
        cell * cellUnits
    }
}

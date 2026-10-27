/// 面の種類（FR-02a）。
public enum StageKind: Sendable, Hashable, CaseIterable {
    /// 1 面: 草原。
    case grassland
    /// 2 面: 結晶の洞窟（滑る床・梯子・縦の区間・消える足場）。
    case cavern
    /// 3 面: 空中の足場（動く足場・落ちる穴）。
    case sky
    /// 4 面: 要塞（コンベア・棘・消える足場・ボス）。
    case fortress
}

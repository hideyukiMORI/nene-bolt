/// 面の 1 セルの地形（FR-02a・FR-02b・ADR 0005）。閉じた enum。
public enum Terrain: Sendable, Hashable {
    /// 空き。
    case empty
    /// 固い床と壁。
    case solid
    /// 滑る床（結晶の洞窟）。固いが、足が止まりにくい。
    case ice
    /// 梯子。上り下りできる。いちばん上の段は上から乗れる。
    case ladder
    /// 棘。触れると 1 機失う。
    case spike
    /// 消える足場（組の番号 0〜3）。組ごとに決まった間隔で現れて消える。
    case vanishing(group: Int)
    /// ベルトコンベア。乗っていると向きへ流される。
    case conveyor(Heading)
}

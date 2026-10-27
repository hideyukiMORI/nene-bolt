/// 1 刻みで起きたこと。セリフと演出の入力になる。
public enum GameEvent: Sendable, Hashable {
    /// 面が始まった。
    case stageStarted(Stage)
    /// ゴールに着いた。
    case stageCleared(Stage)
    /// ゴールに着いたときの残り時間のボーナス（得点）。
    case timeBonus(points: Int)
    /// 敵を倒した（種類・得点・場所・倒し方）。
    case enemyDefeated(EnemyKind, points: Int, at: Point, by: DefeatMethod)
    /// 弾が敵に当たったが、まだ倒れない。
    case enemyHit(at: Point)
    /// 溜め撃ちを撃った。
    case chargedShot
    /// 自機が被弾した（減った体力）。
    case runnerHit(damage: Int)
    /// 1 機失った。
    case lifeLost(LossCause)
    /// 中間地点か始まりからやり直した。
    case respawned
    /// 拾った。
    case pickedUp(PickupKind)
    /// コインが 100 枚になって 1UP した。
    case coinsOneUp
    /// 中間地点を通った。
    case checkpointReached
    /// 制限時間が残り 30 秒になった。
    case hurryUp
    /// ボスの部屋の扉が閉じ、ボス戦が始まった。
    case bossAppeared
    /// ボスに当たった（残りの体力）。
    case bossHit(healthLeft: Int)
    /// ボスが光った。
    case bossFlash
    /// ボスを倒した（得点）。
    case bossDefeated(points: Int)
    /// ゲームが終わった。
    case gameOver(GameEnding)
}

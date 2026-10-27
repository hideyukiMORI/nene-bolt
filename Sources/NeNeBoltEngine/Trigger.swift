/// ランナーの撃ち方。
enum Trigger: Sendable, Hashable {
    /// 敵が前にいれば連射する。
    case rapid
    /// 撃つボタンを押し続けて溜め、敵が前に来たら離して溜め撃ちを出す。
    case charge
}

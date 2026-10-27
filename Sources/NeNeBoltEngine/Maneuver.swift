import NeNeBoltCore

/// 先読みで試す動きの 1 つ（ADR 0008）。`delay` 刻み待ってから、`move` を押し続け、跳ぶを `jump` 刻みだけ押す。
struct Maneuver: Sendable, Hashable {
    let move: Buttons
    let jump: Int
    let delay: Int

    /// 試す動きの一覧。左・右・止まるのそれぞれで、走る・長く跳ぶ・短く跳ぶ・待ってから跳ぶ（消える足場の間合い）と、梯子の上り下り。
    static let all: [Maneuver] = {
        var list: [Maneuver] = []
        for move in [Buttons.right, .left, []] {
            list.append(Maneuver(move: move, jump: 0, delay: 0))
            list.append(Maneuver(move: move, jump: 20, delay: 0))
            list.append(Maneuver(move: move, jump: 6, delay: 0))
            for delay in [6, 12, 20] {
                list.append(Maneuver(move: move, jump: 20, delay: delay))
            }
        }
        list.append(Maneuver(move: .right, jump: 0, delay: 12))
        list.append(Maneuver(move: .up, jump: 0, delay: 0))
        list.append(Maneuver(move: [.up, .right], jump: 0, delay: 0))
        list.append(Maneuver(move: [.up, .left], jump: 0, delay: 0))
        list.append(Maneuver(move: .down, jump: 0, delay: 0))
        return list
    }()

    /// 先読みで、動きをそのまま続ける刻みの数（待つ間を除く）。その先は続きの動きに替える。
    static let span = 16

    /// 先読みの 2 段目で試す続きの動き。止まる・左右へ走る・左右へ跳ぶ・その場で跳ぶ。
    static let followUps: [Maneuver] = [
        Maneuver(move: [], jump: 0, delay: 0),
        Maneuver(move: .right, jump: 0, delay: 0),
        Maneuver(move: .left, jump: 0, delay: 0),
        Maneuver(move: .right, jump: 20, delay: 0),
        Maneuver(move: .left, jump: 20, delay: 0),
        Maneuver(move: [], jump: 20, delay: 0),
    ]

    /// 始めてから `elapsed` 刻み目に押すボタン（撃つは含まない）。待つ間も左右は押す（助走をつける）。
    func buttons(at elapsed: Int) -> Buttons {
        guard elapsed >= delay else {
            return move.subtracting([.up, .down])
        }
        var buttons = move
        if elapsed - delay < jump {
            buttons.insert(.jump)
        }
        return buttons
    }
}

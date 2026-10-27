import NeNeBoltCore

/// 面の行き先までの道のりの地図（ADR 0008）。ランナーが立てる所（と梯子）を点にし、歩く・梯子・跳ぶ・落ちるでつないで、
/// 行き先から逆にたどった重みの和を道のりにする。
///
/// 跳べるかは大まかに数える（横 3 セル・上 3 段まで、落ちるなら横はもう少し先まで）。途中の天井や消える足場の間合いは見ない。
/// 実際に動けるかは先読み（Core の 1 刻み関数）が決め、この地図は「どちらへ進むと近づくか」の目安だけに使う。
struct Route: Sendable {
    /// 地図の面の番号。
    let stage: Int
    private let columns: Int
    private let rows: Int
    private let distances: [Int]

    /// 届かない所の道のり。
    static let unreachable = 1_000_000

    /// 面の地図から作る。行き先は旗（1〜3 面）か、ボスの部屋（4 面の扉とボスの居る所）。
    static func make(for game: Game) -> Route {
        let map = game.map
        let graph = Graph(game: game)
        var distances = Array(repeating: unreachable, count: map.columns * map.rows)
        var frontier: [Int] = []
        for spawn in map.spawns where spawn.kind == .goal || spawn.kind == .door || spawn.kind == .boss {
            if let node = graph.landing(column: spawn.column, row: spawn.row) {
                distances[node] = 0
                frontier.append(node)
            }
        }
        let reversed = graph.reversedEdges()
        // 重みは小さい整数なので、点の数が少ないうちは単純に「確定していない最小」を選ぶ方法で足りる
        var settled = Array(repeating: false, count: distances.count)
        while let current = frontier.min(by: { distances[$0] < distances[$1] }) {
            frontier.removeAll { $0 == current }
            guard !settled[current] else {
                continue
            }
            settled[current] = true
            for (previous, cost) in reversed[current] where distances[current] + cost < distances[previous] {
                distances[previous] = distances[current] + cost
                frontier.append(previous)
            }
        }
        return Route(stage: game.stage.number, columns: map.columns, rows: map.rows, distances: distances)
    }

    /// 箱の足もとから行き先までの道のり。宙にいるなら、真下の立てる所の道のり。
    func distance(from box: Box) -> Int {
        let column = Field.cell(box.centerX)
        let row = Field.cell(box.bottom - 1)
        guard (0..<columns).contains(column), row < rows else {
            return Route.unreachable
        }
        for below in max(row, 0)..<rows where distances[below * columns + column] < Route.unreachable {
            return distances[below * columns + column]
        }
        return Route.unreachable
    }
}

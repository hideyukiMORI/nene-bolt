/// ハイスコアの上位 5 件（FR-02e）。並べ方はこの型の 1 経路だけ。ファイルの読み書きは合成ルートがする。
///
/// 得点の高い順。同じ得点なら先に入った方が上。
public struct HighScoreTable: Sendable, Hashable {
    /// 表の大きさ。
    public static let capacity = 5

    /// 上から順の記録。
    public let entries: [HighScore]

    /// 記録から表を作る（並べ直して上位 5 件にする）。
    public init(entries: [HighScore]) {
        self.entries = Array(
            entries.enumerated()
                .sorted {
                    $0.element.score != $1.element.score ? $0.element.score > $1.element.score : $0.offset < $1.offset
                }
                .map(\.element)
                .prefix(HighScoreTable.capacity))
    }

    /// 空の表。
    public static let empty = HighScoreTable(entries: [])

    /// 1 件を入れた表と、その順位。同じ得点の記録が既にあれば、その下に入る。
    public func inserting(_ entry: HighScore) -> HighScoreInsertion {
        let position = entries.filter { $0.score >= entry.score }.count
        guard position < HighScoreTable.capacity else {
            return HighScoreInsertion(table: self, rank: .unranked)
        }
        var placed = entries
        placed.insert(entry, at: position)
        return HighScoreInsertion(table: HighScoreTable(entries: placed), rank: .ranked(position + 1))
    }

    /// 1 位の得点（表が空なら 0）。
    public var best: Int { entries.first?.score ?? 0 }
}

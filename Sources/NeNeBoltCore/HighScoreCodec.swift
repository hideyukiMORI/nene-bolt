/// ハイスコアの表とファイルの中身の読み書き（FR-02e・ARC-009・ADR 0011）。形式はこの 1 経路だけで、ファイルの読み書きは合成ルートがする。
///
/// 形式（版 1）: 1 行目が `nene-bolt-highscores 1`、2 行目から 1 件 1 行で `得点<TAB>ステージ<TAB>難易度<TAB>パイロット`。
/// 読めない版や壊れた行は、既定値へ黙って落とさず型のある失敗で返す。
public enum HighScoreCodec {
    /// 版の行。
    public static let header = "nene-bolt-highscores 1"

    /// 表を書く（最後に改行）。
    public static func encode(_ table: HighScoreTable) -> String {
        let lines = table.entries.map { entry in
            [String(entry.score), String(entry.stage), name(of: entry.difficulty), entry.pilot].joined(separator: "\t")
        }
        return ([header] + lines).joined(separator: "\n") + "\n"
    }

    /// 中身を読む。
    public static func decode(_ text: String) -> HighScoreDecodeOutcome {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard lines.first == header else {
            return .rejected(.unknownVersion)
        }
        var entries: [HighScore] = []
        for (offset, line) in lines.dropFirst().enumerated() where !line.isEmpty {
            guard let entry = entry(line) else {
                return .rejected(.malformedLine(offset + 2))
            }
            entries.append(entry)
        }
        return .decoded(HighScoreTable(entries: entries))
    }

    private static func entry(_ line: String) -> HighScore? {
        let fields = line.split(separator: "\t", omittingEmptySubsequences: false).map(String.init)
        guard fields.count == 4, let score = Int(fields[0]), score >= 0, let stage = Int(fields[1]), stage >= 1,
            let difficulty = Difficulty.allCases.first(where: { name(of: $0) == fields[2] }), !fields[3].isEmpty,
            fields[3].count <= 16
        else {
            return nil
        }
        return HighScore(score: score, pilot: fields[3], stage: stage, difficulty: difficulty)
    }

    private static func name(of difficulty: Difficulty) -> String {
        switch difficulty {
        case .easy: "easy"
        case .normal: "normal"
        case .hard: "hard"
        }
    }
}

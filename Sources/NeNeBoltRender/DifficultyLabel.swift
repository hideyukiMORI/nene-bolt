import NeNeBoltCore

/// 難易度の名前（画面と起動オプションで同じ綴り）。
public enum DifficultyLabel {
    /// `EASY` / `NORMAL` / `HARD`。
    public static func text(_ difficulty: Difficulty) -> String {
        Wording.difficulty(difficulty)
    }
}

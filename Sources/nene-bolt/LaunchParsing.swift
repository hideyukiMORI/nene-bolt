/// 起動オプションを読んだ結果。
enum LaunchParsing {
    case parsed(LaunchOptions)
    /// 読めなかった理由（1 行）。
    case rejected(String)
}

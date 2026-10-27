/// win32-input-mode の列を 1 つ読んだ結果。
enum Win32Read: Sendable, Hashable {
    /// 知っているキーの出来事。
    case event(KeyEvent)
    /// その方式の列だが、知らないキー（Shift 単独など）。
    case unknownKey
    /// その方式の列ではない。
    case other
}

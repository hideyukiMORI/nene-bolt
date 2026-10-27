/// 箱を 1 軸に動かした結果。
struct Slide: Sendable, Hashable {
    /// 動いたあとの箱。
    let box: Box
    /// 途中で何かにぶつかって止まったか。
    let blocked: Bool
}

/// 背景の 1 層（ADR 0010）。カメラの何分の 1 で流れるか・点の字・置き場所をずらす値。
struct BackdropLayer: Sendable, Hashable {
    let divisor: Int
    let glyph: String
    let salt: Int
}

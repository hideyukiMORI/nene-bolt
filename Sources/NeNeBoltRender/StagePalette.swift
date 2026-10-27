import NeNeBoltCore

/// 面ごとの地形の色（FR-12・ADR 0010）。テーマの岩と据え付けの色に面の色合いを混ぜて作る。
///
/// 草原は緑、結晶の洞窟は青と水色（Q5）、空は雲の白っぽい青、要塞は鋼の灰と赤い梁。混ぜた色が地に対して 3:1 に届かなければ、
/// 届くまで文字の色へ寄せる（暗いテーマでも明るいテーマでも、地形が地に沈まない）。
struct StagePalette: Sendable, Hashable {
    /// 固い地形の色。
    let rock: Rgb
    /// 滑る床（結晶）の色。
    let ice: Rgb
    /// 梯子・動く足場・消える足場の色。
    let fixture: Rgb
    /// 遠くの背景の点の色。
    let far: Rgb
    /// 近くの背景の点の色。
    let near: Rgb

    /// テーマと面から作る。
    static func make(theme: Theme, stage: StageKind) -> StagePalette {
        let hue = hues(stage)
        let (rockHue, iceHue, fixtureHue) = (hue[0], hue[1], hue[2])
        let rock = visible(Rgb.mix(theme.rock, rockHue, percent: 55), theme: theme)
        let ice = visible(Rgb.mix(theme.rock, iceHue, percent: 65), theme: theme)
        let fixture = visible(Rgb.mix(theme.fixture, fixtureHue, percent: 50), theme: theme)
        return StagePalette(
            rock: rock, ice: ice, fixture: fixture, far: Rgb.mix(theme.ground, theme.star, percent: 70),
            near: Rgb.mix(theme.ground, rockHue, percent: 30))
    }

    /// 面の色合い（岩・氷・据え付けの順）。
    private static func hues(_ stage: StageKind) -> [Rgb] {
        switch stage {
        case .grassland: [hex(0x4C9A3C), hex(0x9FE0FF), hex(0xC8964E)]
        case .cavern: [hex(0x2E5FB8), hex(0x7FE7FF), hex(0x5FC8FF)]
        case .sky: [hex(0xC8DCF5), hex(0xE6F4FF), hex(0xF2DC8C)]
        case .fortress: [hex(0x7A808E), hex(0xA9C4D8), hex(0xC8463C)]
        }
    }

    /// 地に対して 3:1 に届くまで、文字の色へ 10% ずつ寄せる（最大 10 回）。
    private static func visible(_ color: Rgb, theme: Theme) -> Rgb {
        var result = color
        for _ in 0..<10 where !Luminance.contrasts(result, theme.ground, atLeast: 3) {
            result = Rgb.mix(result, theme.text, percent: 10)
        }
        return result
    }

    private static func hex(_ value: UInt32) -> Rgb {
        Rgb(red: UInt8(value >> 16 & 0xFF), green: UInt8(value >> 8 & 0xFF), blue: UInt8(value & 0xFF))
    }
}

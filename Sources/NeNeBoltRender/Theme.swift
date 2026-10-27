import NeNeBoltCore

/// カラーテーマ。色の値を持つのはここだけ（FR-12）。12 種類で、実行中の `t` で順に替える。
///
/// 12 色の並びと値は兄弟の 12 テーマ（NeNe Swarm `Sources/NeNeSwarmRender/Theme.swift`・コミット a660f47。元は NeNe Igo）をそのまま写した。
/// 地・パネル・枠・文字・控えめな文字・強調 2 色は兄弟と同じ意味で使う。自機・敵・弾・地形などの 11 色は、仮に Swarm の 11 色を
/// 役を替えて当てた（ADR 0007）。面ごとの地形の色は、この岩と据え付けの色から `StagePalette` が作る（ADR 0010）。
public struct Theme: Sendable, Hashable {
    /// 画面と起動オプションに使う名前（`--theme NEON`）。
    public let name: String
    let ground: Rgb
    let panel: Rgb
    let frame: Rgb
    let text: Rgb
    let dim: Rgb
    let accent: Rgb
    let accentAlt: Rgb
    /// 自機の色。
    let runner: Rgb
    /// 自機の弾の色。
    let runnerShot: Rgb
    /// 歩く敵・跳ねる敵の色。
    let foe: Rgb
    /// 飛ぶ敵・割れる結晶の色。
    let foeAlt: Rgb
    /// ボスの色。
    let boss: Rgb
    /// 敵の弾と棘の色。
    let danger: Rgb
    /// 固い地形の色。
    let rock: Rgb
    /// 拾うものの色。
    let pickup: Rgb
    /// 梯子・動く足場・消える足場の色。
    let fixture: Rgb
    /// 溜め撃ちと帯の大きな文字の色。
    let spark: Rgb
    /// 遠くの背景の飾りの色（暗く）。
    let star: Rgb

    public static let catalog: [Theme] = [
        Theme(
            name: "NEON",
            hex: [
                0x05070D, 0x0A1020, 0x1E4D6B, 0xC8D3E0, 0x6B7F99, 0x00E5FF,
                0xFF2E97, 0x3D6781, 0xE4E9F0, 0x80F2FF, 0x0B0B0F, 0xEAFBFF,
            ],
            sprites: [
                0x00E5FF, 0xFFFFFF, 0xFF2E97, 0xFFD23F, 0x7CFF6B, 0xFF5C5C,
                0x2F8F9D, 0xB388FF, 0x3A5A8C, 0xFFF4A3, 0x2A3550,
            ]),
        Theme(
            name: "PHOSPHOR",
            hex: [
                0x020803, 0x061208, 0x1C4D24, 0x9CF5A8, 0x4F9A5B, 0x39FF6A,
                0xD8FF3E, 0x406D47, 0xCEFAD4, 0xD8FF3E, 0x0B0B0F, 0xE4FFE8,
            ],
            sprites: [
                0x39FF6A, 0xE4FFE8, 0xD8FF3E, 0x00E0A0, 0xF5FFB0, 0xFFB000,
                0x2E8A3E, 0xFF6A1A, 0x1E5A2A, 0xFFFFFF, 0x173D1E,
            ]),
        Theme(
            name: "AMBER",
            hex: [
                0x0A0602, 0x140C04, 0x5A3A12, 0xFFC879, 0xA87A3C, 0xFFB000,
                0xFF6A1A, 0x795D37, 0xFFE4BC, 0xFFFFFF, 0x0B0B0F, 0xFFF1D6,
            ],
            sprites: [
                0xFFB000, 0xFFF1D6, 0xFF6A1A, 0xFFE066, 0xFFFFFF, 0xFF3B30,
                0x9A6420, 0x6EC6FF, 0x5A3A12, 0xFFF1D6, 0x3A2810,
            ]),
        Theme(
            name: "SYNTHWAVE",
            hex: [
                0x0D0221, 0x160534, 0x4B1D7A, 0xE7D7FF, 0x9A84C4, 0xFF3CAC,
                0x00F0FF, 0x78539A, 0xF3EBFF, 0xFFFFFF, 0x0B0B0F, 0xFFF4FB,
            ],
            sprites: [
                0x00F0FF, 0xFFFFFF, 0xFF3CAC, 0xFFD319, 0xB967FF, 0xFF6E6E,
                0x8A6AD8, 0x72F1B8, 0x4B1D7A, 0xFFF4FB, 0x2E1A55,
            ]),
        Theme(
            name: "GLACIER",
            hex: [
                0x03080F, 0x08121E, 0x2A4A6A, 0xDCEBFA, 0x7E98B3, 0x7FD4FF,
                0xB6A0FF, 0x4A6580, 0xDCEBFA, 0xBFEAFF, 0x0B0B0F, 0xFFFFFF,
            ],
            sprites: [
                0x7FD4FF, 0xFFFFFF, 0xB6A0FF, 0x9DF5E0, 0xFFE6A8, 0xFF8FA3,
                0x4A7AA0, 0xFFD27F, 0x2A4A6A, 0xFFFFFF, 0x1A2A3D,
            ]),
        Theme(
            name: "BLOODMOON",
            hex: [
                0x080203, 0x130507, 0x5A1620, 0xF2D0D4, 0xA06A72, 0xFF2B3F,
                0xFFB347, 0x88535B, 0xF8E8EA, 0xFFFFFF, 0x0B0B0F, 0xFFF0F1,
            ],
            sprites: [
                0xFFB347, 0xFFF0F1, 0xFF2B3F, 0xFF7A8A, 0xF2D0D4, 0xFF5A1F,
                0x9A3A44, 0xFFE14D, 0x5A1620, 0xFFF0F1, 0x3A1015,
            ]),
        Theme(
            name: "VAPOR",
            hex: [
                0x120B1F, 0x1C1230, 0x5A3F7F, 0xF3E8FF, 0xA897C4, 0x7DF9FF,
                0xFF9DE2, 0x6F5890, 0xF3E8FF, 0x7DF9FF, 0x0B0B0F, 0xFFFFFF,
            ],
            sprites: [
                0x7DF9FF, 0xFFFFFF, 0xFF9DE2, 0xFFF59D, 0xB39DFF, 0xFF6FAE,
                0x8A70AE, 0x9DFFB0, 0x5A3F7F, 0xFFFFFF, 0x2E2245,
            ]),
        Theme(
            name: "MONO",
            hex: [
                0x050505, 0x101010, 0x3A3A3A, 0xD9D9D9, 0x8A8A8A, 0xFFFFFF,
                0xBDBDBD, 0x636363, 0xECECEC, 0xFFFFFF, 0x0B0B0F, 0xFFFFFF,
            ],
            sprites: [
                0xFFFFFF, 0xFFFFFF, 0xA8A8A8, 0x8C8C8C, 0xD0D0D0, 0xEDEDED,
                0x6A6A6A, 0xBDBDBD, 0x3A3A3A, 0xFFFFFF, 0x262626,
            ]),
        Theme(
            name: "TOXIC",
            hex: [
                0x06040A, 0x0F0A16, 0x3E2A5A, 0xE2F5C8, 0x8E9A78, 0xB6FF00,
                0xC266FF, 0x6A5D7C, 0xE2F5C8, 0xB6FF00, 0x0B0B0F, 0xF4FFE6,
            ],
            sprites: [
                0xB6FF00, 0xF4FFE6, 0xC266FF, 0xFF4FD8, 0xFFE14D, 0xFF5A36,
                0x7A609E, 0x39F0FF, 0x3E2A5A, 0xF4FFE6, 0x241A33,
            ]),
        Theme(
            name: "GILDED",
            hex: [
                0x070605, 0x11100C, 0x4A3F22, 0xEDE3C8, 0x9C9278, 0xE8C15A,
                0x5AD1C8, 0x6C6247, 0xEDE3C8, 0xF4E0AC, 0x0B0B0F, 0xFFF8E6,
            ],
            sprites: [
                0xE8C15A, 0xFFF8E6, 0x5AD1C8, 0xD98C5F, 0xFFF1C1, 0xFF6B5A,
                0x8A7A4C, 0xB39CFF, 0x4A3F22, 0xFFF8E6, 0x2E2A1E,
            ]),
        Theme(
            name: "ABYSS",
            hex: [
                0x01060A, 0x041018, 0x123A4F, 0xCBE7F2, 0x6E93A3, 0x00C2A8,
                0x3D8BFF, 0x436777, 0xCBE7F2, 0xFFFFFF, 0x0B0B0F, 0xE9FFFB,
            ],
            sprites: [
                0x00C2A8, 0xE9FFFB, 0x3D8BFF, 0x9B7BFF, 0xCBE7F2, 0xFF6F61,
                0x2A7A8F, 0xFFD166, 0x123A4F, 0xE9FFFB, 0x0E2A38,
            ]),
        Theme(
            name: "PAPER",
            hex: [
                0xF4F1EA, 0xE6E1D6, 0xB8AE9A, 0x2A2622, 0x5E564C, 0x0060C7,
                0xA81D33, 0x94876D, 0x000000, 0x4A0012, 0x1A1714, 0xF4F4F0,
            ],
            sprites: [
                0x0060C7, 0x1A1714, 0xA81D33, 0x7A4F00, 0x2E7D32, 0xC2185B,
                0x8C7E64, 0x6A1B9A, 0xD2C8B6, 0x1A1714, 0xD9D2C3,
            ]),
    ]

    /// 既定のテーマ。
    public static let standard = catalog[0]

    /// 名前のテーマ（大文字小文字を区別しない）。無ければ nil。
    public static func named(_ name: String) -> Theme? {
        catalog.first { $0.name == name.uppercased() }
    }

    /// `t` を押したときの次のテーマ（最後の次は最初）。
    public var next: Theme {
        let index = Self.catalog.firstIndex(of: self) ?? 0
        return Self.catalog[(index + 1) % Self.catalog.count]
    }

    /// 兄弟と同じ順の 12 色（地・パネル・枠・文字・控えめな文字・強調 2 色と、使わない 5 色）と、Swarm の 11 色から作る。
    /// 11 色は Swarm の並び（自機・自機の弾・雑魚・護衛・親玉・敵の弾・トーチカ・UFO・ビーム・爆発・星）のまま、
    /// 自機・自機の弾・敵・拾うもの・敵・危険・岩・ボス・（使わない）・光り・背景に当てる。据え付けの色は岩と文字の色から作る。
    private init(name: String, hex: [UInt32], sprites: [UInt32]) {
        precondition(hex.count == 12 && sprites.count == 11, "テーマの色は 12 個と 11 個")
        let rgb = hex.map(Theme.rgb)
        let own = sprites.map(Theme.rgb)
        runner = own[0]
        runnerShot = own[1]
        foe = own[2]
        pickup = own[3]
        foeAlt = own[4]
        danger = own[5]
        rock = own[6]
        boss = own[7]
        spark = own[9]
        star = own[10]
        self.name = name
        // 梯子・動く足場・消える足場は、岩を文字の色へ寄せた色（Swarm のビームの色は飾りの暗さで、地に対して 3:1 に届かない）
        fixture = Rgb.mix(own[6], rgb[3], percent: 45)
        ground = rgb[0]
        panel = rgb[1]
        frame = rgb[2]
        text = rgb[3]
        dim = rgb[4]
        accent = rgb[5]
        accentAlt = rgb[6]
    }

    private static func rgb(_ hex: UInt32) -> Rgb {
        Rgb(red: UInt8(hex >> 16 & 0xFF), green: UInt8(hex >> 8 & 0xFF), blue: UInt8(hex & 0xFF))
    }

    /// 敵の種類ごとの色。
    func color(of kind: EnemyKind) -> Rgb {
        switch kind {
        case .walker, .hopper, .turret: foe
        case .flyer, .splitter, .shard: foeAlt
        }
    }
}

/// 上端の題の帯と、下端のキーのヘルプ（FR-15: スクリーンセーバーのキーと遊びのキーを常に出す）。
enum ScreenChrome {
    /// ` ▌NENE//BOLT  │  GAME 001  │  SEED 0x…  │  24BIT`
    static func header(_ state: ScreenState, glyphs: FrameGlyphs) -> [Segment] {
        let theme = state.display.theme
        let divider = Segment("  " + glyphs.vertical + "  ", theme.frame)
        return [
            Segment(" " + glyphs.marker + Wording.title, theme.accent), divider,
            Segment(Wording.game(state.gameNumber), theme.text), divider,
            Segment(Wording.seed(state.seed), theme.text), divider,
            Segment(Wording.colors(state.display.traits.colors), theme.dim),
        ]
    }

    /// COMMS: ランナーの顔とセリフ（新しい方が下・`rows` 行まで）。古い方は控えめな色。
    static func comms(_ state: ScreenState, glyphs: FrameGlyphs, rows: Int) -> [[Segment]] {
        let theme = state.display.theme
        let shown = Array(state.remarks.suffix(rows))
        guard !shown.isEmpty else {
            return [[Segment(" " + glyphs.marker, theme.dim)]]
        }
        return shown.enumerated().map { index, remark in
            let lead = " " + glyphs.marker + remark.persona.face + " "
            guard index == shown.count - 1 else {
                return [Segment(lead + remark.text, theme.dim)]
            }
            return [Segment(lead, theme.accent), Segment(remark.text, theme.text)]
        }
    }

    /// `[q] QUIT  [t] THEME NEON  [d] NORMAL  ARROWS MOVE  Z JUMP  X FIRE`
    static func footer(_ state: ScreenState) -> [Segment] {
        let theme = state.display.theme
        return [
            Segment(" " + Wording.quitKey, theme.accent), Segment(Wording.quitName, theme.dim),
            Segment(Wording.themeKey, theme.accent), Segment(Wording.themeName, theme.dim),
            Segment(theme.name + "  ", theme.text),
            Segment(Wording.difficultyKey, theme.accent), Segment(Wording.difficultyName, theme.dim),
            Segment(Wording.difficulty(state.difficulty), theme.text),
            Segment(Wording.playKeys, theme.dim),
        ]
    }
}

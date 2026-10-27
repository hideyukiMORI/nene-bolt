import Testing

@testable import NeNeBoltCore
@testable import NeNeBoltEngine
@testable import NeNeBoltRender

/// 面ごとの色・背景・演出・広い配置（FR-02h・FR-12・ADR 0010）。
struct EffectsTests {
    /// 整数の明るさの表は、浮動小数点の WCAG の計算と 1% 以内で合う。
    @Test func theIntegerLuminanceMatchesTheFloatingPointOne() {
        for value in stride(from: 0, through: 255, by: 5) {
            let gray = Rgb(red: UInt8(value), green: UInt8(value), blue: UInt8(value))
            let exact = Contrast.luminance(gray) * 10_000
            #expect(abs(Double(Luminance.of(gray)) - exact) <= max(exact * 0.01, 2), "\(value)")
        }
        let white = Rgb(red: 255, green: 255, blue: 255)
        let black = Rgb(red: 0, green: 0, blue: 0)
        #expect(Luminance.contrasts(white, black, atLeast: 21))
        #expect(!Luminance.contrasts(black, black, atLeast: 2))
    }

    /// どのテーマのどの面でも、岩・結晶・据え付けは地に対して 3:1 以上。結晶の洞窟の岩は青い（B が R より大きい）。
    @Test(arguments: Theme.catalog)
    func everyStagePaletteStandsOutFromTheGround(_ theme: Theme) {
        for stage in StageKind.allCases {
            let palette = StagePalette.make(theme: theme, stage: stage)
            for (name, color) in [("rock", palette.rock), ("ice", palette.ice), ("fixture", palette.fixture)] {
                #expect(Contrast.ratio(color, theme.ground) >= 3, "\(theme.name) \(stage) \(name)")
            }
        }
        let cavern = StagePalette.make(theme: .standard, stage: .cavern)
        #expect(cavern.rock.blue > cavern.rock.red)
        #expect(cavern.ice.blue > cavern.ice.red)
    }

    static func playing(ticks: Int, size: ScreenSize = ScreenRendererTests.size, effects: Effects = Effects()) -> Grid {
        let state = ScreenState(
            session: ScreenRendererTests.session(ticks: ticks), display: ScreenRendererTests.boxed, difficulty: .normal,
            seed: 9, highScores: .empty, pilot: .autopilot(name: "DASH.EXE", face: "(>o>)"), keys: .unknown,
            storage: .file, talk: ([], effects))
        return ScreenRenderer.render(state, size: size)
    }

    /// 背景の点は ASCII の 1 文字で、地の上にだけ置く（塗ったセルに文字が無い・FR-07）。
    @Test func theBackdropIsAsciiDotsOnTheGroundOnly() {
        let grid = Self.playing(ticks: 300)
        let layout = ScreenLayout.compact
        var dots = 0
        for row in layout.fieldRow..<(layout.fieldRow + layout.fieldHeight) {
            for column in layout.fieldColumn..<(layout.fieldColumn + layout.fieldWidth) {
                let cell = grid[column, row]
                guard cell.character != " " else {
                    continue
                }
                dots += 1
                #expect(cell.background == Theme.standard.ground)
                #expect(cell.character.isASCII)
            }
        }
        #expect(dots > 10)
    }

    /// 倒した場所に得点が浮かび、30 刻みで消える。
    @Test func popupsFloatAndFade() {
        var effects = Effects()
        effects.absorb([.game(.enemyDefeated(.walker, points: 100, at: Point(x: 0, y: 0), by: .shot))])
        #expect(effects.popups.count == 1)
        for _ in 0..<Effects.popupTicks {
            effects.absorb([])
        }
        #expect(effects.popups.isEmpty)
    }

    /// ボスが現れたら WARNING の帯を出す。
    @Test func aBossBringsAWarningBanner() {
        var effects = Effects()
        effects.absorb([.game(.bossAppeared)])
        #expect(effects.showsWarning)
        let grid = Self.playing(ticks: 300, effects: effects)
        let layout = ScreenLayout.compact
        let text = "WARNING"
        let left = layout.fieldColumn + (layout.fieldWidth - BigFont.span(text) * 2) / 2
        let pixels = BigFont.pixels(text)
        let lit = pixels[0].firstIndex(of: true) ?? 0
        #expect(grid[left + lit * 2, layout.fieldRow + 4].background == Theme.standard.danger)
    }

    /// 100 × 26 以上では、窓が 49 セル幅になり、COMMS が 2 行になる。
    @Test func aLargeTerminalGetsAWiderViewAndTwoCommsLines() {
        #expect(ScreenRenderer.largeSize == ScreenSize(columns: 100, rows: 26))
        let older = Remark(persona: .dash, cue: .stageStart, text: "Spoiler: the exit is on the right.")
        let newer = Remark(persona: .dash, cue: .hit, text: "Ow. That cost me a tenth of a second.")
        let state = ScreenState(
            session: ScreenRendererTests.session(ticks: 300), display: ScreenRendererTests.boxed, difficulty: .normal,
            seed: 9, highScores: .empty, pilot: .autopilot(name: "DASH.EXE", face: "(>o>)"), keys: .unknown,
            storage: .file, talk: ([older, newer], Effects()))
        let large = ScreenRendererTests.text(ScreenRenderer.render(state, size: ScreenRenderer.largeSize))
        #expect(large.contains("Spoiler: the exit is on the right."))
        #expect(large.contains("Ow. That cost me a tenth of a second."))
        #expect(large.contains("[q] QUIT"))
        let lines = large.split(separator: "\n")
        #expect(lines[1].count == 100)
        let compact = ScreenRendererTests.text(ScreenRenderer.render(state, size: ScreenSize(columns: 99, rows: 26)))
        #expect(!compact.contains("Spoiler: the exit"))
        #expect(compact.contains("Ow. That cost me"))
    }
}

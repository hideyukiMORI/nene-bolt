import NeNeBoltCore
import Testing

@testable import NeNeBoltEngine
@testable import NeNeBoltRender

/// 1 画面分の格子（FR-07・FR-10・FR-13・FR-15・FR-16・ADR 0007）。
struct ScreenRendererTests {
    static let boxed = DisplayOptions(theme: .standard, traits: TerminalTraits(frame: .boxDrawing, colors: .trueColor))
    static let size = ScreenSize(columns: 80, rows: 24)

    /// シード 9 の場面を `ticks` 刻み進めたもの（DASH.EXE が走る）。
    static func session(ticks: Int) -> Session {
        var generator = SplitMix64(seed: 9)
        var pilotGenerator = SplitMix64(seed: 10)
        var pilot = Pilot(persona: .dash)
        var session = Session(durations: SceneDurations(titleTicks: 30, gameOverTicks: 30))
        for _ in 0..<ticks {
            var buttons: Buttons = []
            if case .play(let game) = session.scene {
                buttons = pilot.buttons(for: game, difficulty: .normal, using: &pilotGenerator)
            }
            session = session.step(buttons, difficulty: .normal, using: &generator).session
        }
        return session
    }

    static func state(
        _ session: Session, display: DisplayOptions = boxed,
        pilot: PilotLabel = .autopilot(name: "BOLT.EXE", face: "(o_o)"),
        keys: KeyReading = .unknown
    ) -> ScreenState {
        ScreenState(
            session: session, display: display, difficulty: .normal, seed: 9,
            highScores: HighScoreTable(entries: [HighScore(score: 4_321, pilot: "PLAYER", stage: 2, difficulty: .easy)]
            ),
            pilot: pilot, keys: keys, storage: .memoryOnly,
            talk: ([Remark(persona: .glitch, cue: .hit, text: "Ow. Was that me? That was me.")], Effects()))
    }

    static func render(_ session: Session, display: DisplayOptions = boxed, size: ScreenSize = size) -> Grid {
        ScreenRenderer.render(state(session, display: display), size: size)
    }

    static func text(_ grid: Grid) -> String {
        (0..<grid.size.rows).map { row in String((0..<grid.size.columns).map { grid[$0, row].character }) }
            .joined(separator: "\n")
    }

    @Test func theScreenFitsEightyByTwentyFour() {
        #expect(ScreenRenderer.minimumSize == ScreenSize(columns: 80, rows: 24))
    }

    @Test(arguments: [0, 40, 400, 2_000])
    func keyHelpAndHeaderAreAlwaysShown(_ ticks: Int) {
        let text = Self.text(Self.render(Self.session(ticks: ticks)))
        #expect(text.contains("[q] QUIT"))
        #expect(text.contains("[t] THEME NEON"))
        #expect(text.contains("[d] NORMAL"))
        #expect(text.contains("ARROWS MOVE  Z JUMP  X FIRE"))
        #expect(text.contains("NENE//BOLT"))
        #expect(text.contains("PILOT AUTO BOLT.EXE"))
    }

    @Test func theTitleShowsTheHighScoreTableAndHowToTakeOver() {
        let text = Self.text(Self.render(Self.session(ticks: 0)))
        #expect(text.contains("HIGH SCORES"))
        #expect(text.contains("0004321  PLAYER"))
        #expect(text.contains("PRESS ARROWS, Z OR X TO TAKE OVER"))
        #expect(text.contains("GAME 001"))
    }

    /// HUD に、人が操作していることと AI に戻るまでの秒、キー入力の方式が出る（FR-04a・FR-04b・FR-10）。
    @Test func theHudTellsWhoIsPlayingAndHowKeysArrive() {
        let state = Self.state(Self.session(ticks: 200), pilot: .player(secondsLeft: 27), keys: .pressAndRelease)
        let text = Self.text(ScreenRenderer.render(state, size: Self.size))
        #expect(text.contains("PILOT PLAYER 27s"))
        #expect(text.contains("KEYS PRESS/RELEASE"))
        #expect(text.contains("LIVES 04"))
        #expect(text.contains("STAGE 1"))
    }

    /// 面の始まりは、大きな文字の帯を塗って出す（点は空白のセル・1 点＝2 桁・FR-02h）。
    @Test func aStageOpensWithABigBanner() {
        let grid = Self.render(Self.session(ticks: 40))
        let text = "STAGE 1"
        let left = ScreenLayout.compact.fieldColumn + (ScreenLayout.compact.fieldWidth - BigFont.span(text) * 2) / 2
        for (row, cells) in BigFont.pixels(text).enumerated() {
            for (offset, lit) in cells.enumerated() {
                for half in 0..<2 {
                    let cell = grid[left + offset * 2 + half, ScreenLayout.compact.fieldRow + 4 + row]
                    #expect(!lit || cell.background == Theme.standard.spark)
                    #expect(!lit || cell.character == " ")
                }
            }
        }
        #expect(Self.text(grid).contains("GRASSLAND"))
    }

    /// 自機・敵・弾・地形・拾うもののセルは空白で、背景だけが色になる（FR-07）。面の窓の中で地の色でないセルに文字は無い。
    @Test(arguments: [100, 300, 600, 900])
    func spritesArePaintedCellsWithoutCharacters(_ ticks: Int) {
        let session = Self.session(ticks: ticks)
        guard case .play(let game) = session.scene, case .playing = game.phase else {
            return
        }
        let grid = Self.render(session)
        var painted = 0
        for row in ScreenLayout.compact.fieldRow..<(ScreenLayout.compact.fieldRow + ScreenLayout.compact.fieldHeight) {
            for column in ScreenLayout.compact
                .fieldColumn..<(ScreenLayout.compact.fieldColumn + ScreenLayout.compact.fieldWidth)
            {
                let cell = grid[column, row]
                if cell.background != Theme.standard.ground {
                    painted += 1
                    #expect(cell.character == " ")
                }
            }
        }
        #expect(painted > 0)
    }

    /// 自機はいつも面の窓の中に映る（カメラが追う）。体は 2 桁で、自機の色のセルが窓の中にある。
    @Test(arguments: [100, 300, 600, 900, 1_500])
    func theCameraKeepsTheRunnerInView(_ ticks: Int) {
        let session = Self.session(ticks: ticks)
        guard case .play(let game) = session.scene, case .playing = game.phase, game.runner.invulnerable == 0 else {
            return
        }
        let camera = Camera.following(game, layout: .compact)
        let column = camera.column(game.runner.box.centerX)
        let row = camera.row(game.runner.box.bottom - 1)
        #expect((1..<(ScreenLayout.compact.fieldWidth - 1)).contains(column))
        #expect((0..<ScreenLayout.compact.fieldHeight).contains(row))
        let grid = Self.render(session)
        let halves = [column - 1, column].map {
            grid[ScreenLayout.compact.fieldColumn + $0, ScreenLayout.compact.fieldRow + row]
        }
        #expect(halves.allSatisfy { $0.background != Theme.standard.ground })
    }

    /// カメラは面の端で止まり、面の外を映さない。どこに自機がいても、窓は面の中にある。
    @Test(arguments: 1...StageCatalog.count, [ScreenLayout.compact, .large])
    func theCameraStaysInsideTheMap(_ number: Int, _ layout: ScreenLayout) {
        let map = StageCatalog.map(of: Stage(number: number))
        for x in [-100, 0, map.width / 2, map.width - 10, map.width + 100] {
            for y in [-100, 0, map.height / 2, map.height - 10, map.height + 100] {
                let box = Box(origin: Point(x: x, y: y), width: Runner.width, height: Runner.height)
                let camera = Camera.framing(box, map: (map.width, map.height), layout: layout)
                #expect(camera.left >= 0)
                #expect(camera.top >= 0)
                #expect(camera.left + Field.units(layout.viewColumns) <= map.width)
                #expect(camera.top + Field.units(layout.viewRows) <= map.height)
                #expect(camera.left % Camera.unitsPerColumn == 0)
                #expect(camera.top % Field.cellUnits == 0)
            }
        }
    }

    /// COMMS の行に、話したランナーの顔とセリフが出る（ADR 0009）。
    @Test func commsShowsTheFaceAndTheLine() {
        let remark = Remark(persona: .hoard, cue: .hit, text: "Ow! Mind the pockets, they're full.")
        let state = ScreenState(
            session: Self.session(ticks: 200), display: Self.boxed, difficulty: .normal, seed: 9, highScores: .empty,
            pilot: .autopilot(name: "HOARD.ZIP", face: "($_$)"), keys: .unknown, storage: .file,
            talk: ([remark], Effects()))
        let grid = ScreenRenderer.render(state, size: Self.size)
        let row = String((0..<80).map { grid[$0, ScreenLayout.compact.commsRow].character })
        #expect(row.contains("($_$) Ow! Mind the pockets, they're full."))
    }

    /// TITLE に次のランナーの名前と顔が出る。
    @Test func theTitleShowsTheNextRunnerWithItsFace() {
        let text = Self.text(Self.render(Self.session(ticks: 0)))
        #expect(text.contains("NEXT RUNNER BOLT.EXE (o_o)"))
    }

    @Test func aSmallTerminalGetsOneLine() {
        let grid = Self.render(Self.session(ticks: 0), size: ScreenSize(columns: 40, rows: 10))
        #expect(Self.text(grid).hasPrefix("TERMINAL TOO SMALL: NEED 80x24"))
    }

    @Test func anAsciiFrameIsUsedWhenBoxDrawingIsWide() {
        let ascii = DisplayOptions(theme: .standard, traits: TerminalTraits(frame: .ascii, colors: .trueColor))
        let text = Self.text(Self.render(Self.session(ticks: 0), display: ascii))
        #expect(text.contains("+-----"))
        #expect(!text.contains("┌"))
    }

    @Test func everyThemeHasAName() {
        #expect(Theme.catalog.count == 12)
        #expect(Set(Theme.catalog.map(\.name)).count == 12)
        #expect(Theme.named("phosphor")?.name == "PHOSPHOR")
        #expect(Theme.catalog.last?.next == Theme.standard)
    }
}

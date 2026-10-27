import Testing

@testable import NeNeBoltRender
@testable import NeNeBoltTerminal

/// 端末を使わずに確かめられる部分（差分のバイト列・256 色への近似）。端末そのものは `make smoke`（ADR 0007）。
///
/// 移植元: NeNe Swarm `Tests/NeNeSwarmTerminalTests/TerminalTests.swift`（コミット a660f47）。キーの読み取りは `KeyTests` へ移した。
struct TerminalTests {
    static let ink = Rgb(red: 200, green: 200, blue: 200)
    static let ground = Rgb(red: 0, green: 0, blue: 0)

    static func grid(_ text: String) -> Grid {
        var grid = Grid.filled(
            ScreenSize(columns: 4, rows: 2), with: Cell(character: " ", foreground: ink, background: ground))
        grid.write(text, column: 0, row: 0, colors: CellColors(foreground: ink, background: ground))
        return grid
    }

    @Test func firstFrameClearsTheScreenAndWritesEverything() {
        let bytes = String(
            decoding: FrameEncoder.encode(Self.grid("ab"), previous: nil, colors: .trueColor), as: UTF8.self)
        #expect(bytes.hasPrefix("\u{1B}[0m\u{1B}[2J"))
        #expect(bytes.contains("\u{1B}[38;2;200;200;200;48;2;0;0;0m"))
        #expect(bytes.contains("ab"))
    }

    @Test func unchangedFrameWritesNothingAndChangedCellsOnly() {
        let before = Self.grid("ab")
        #expect(FrameEncoder.encode(before, previous: before, colors: .trueColor).isEmpty)
        let bytes = String(
            decoding: FrameEncoder.encode(Self.grid("ac"), previous: before, colors: .trueColor), as: UTF8.self)
        #expect(bytes.hasPrefix("\u{1B}[1;2H"))
        #expect(bytes.contains("c"))
        #expect(!bytes.contains("a"))
    }

    @Test func palette256UsesTheSameNumbersForBothColors() {
        var grid = Self.grid("a")
        grid.paint(column: 1, row: 1, width: 1, color: Self.ink)
        let bytes = String(decoding: FrameEncoder.encode(grid, previous: nil, colors: .palette256), as: UTF8.self)
        #expect(bytes.contains("\u{1B}[38;5;\(Palette256.nearest(Self.ink));48;5;\(Palette256.nearest(Self.ink))m"))
    }

    @Test func cursorReportGivesTheColumn() {
        #expect(CursorReport.column(in: Array("\u{1B}[12;3R".utf8)) == 3)
        #expect(CursorReport.column(in: Array("junk".utf8)) == nil)
    }

    @Test func palette256PicksTheNearestColor() {
        #expect(Palette256.nearest(Rgb(red: 0, green: 0, blue: 0)) == 16)
        #expect(Palette256.nearest(Rgb(red: 255, green: 255, blue: 255)) == 231)
        #expect(Palette256.nearest(Rgb(red: 128, green: 128, blue: 128)) == 244)
    }
}

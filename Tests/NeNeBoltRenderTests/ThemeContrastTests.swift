import NeNeBoltCore
import Testing

@testable import NeNeBoltRender

/// 12 テーマの色の読みやすさ（FR-12・ADR 0007）。
struct ThemeContrastTests {
    /// 自機・敵・弾・地形・据え付け・拾うもの・ボス・光りは、地に対して 3:1 以上。
    @Test(arguments: Theme.catalog)
    func spritesStandOutFromTheGround(_ theme: Theme) {
        let sprites: [(String, Rgb)] = [
            ("runner", theme.runner), ("runnerShot", theme.runnerShot), ("foe", theme.foe), ("foeAlt", theme.foeAlt),
            ("boss", theme.boss), ("danger", theme.danger), ("rock", theme.rock), ("pickup", theme.pickup),
            ("fixture", theme.fixture), ("spark", theme.spark),
        ]
        for (name, color) in sprites {
            #expect(Contrast.ratio(color, theme.ground) >= 3, "\(theme.name) \(name)")
        }
    }

    /// 自機は、どの敵とも違う色（RGB の距離が 60 以上）。
    @Test(arguments: Theme.catalog)
    func theRunnerIsNotColoredLikeAnEnemy(_ theme: Theme) {
        for kind in EnemyKind.allCases {
            #expect(Self.distance(theme.runner, theme.color(of: kind)) >= 60, "\(theme.name) \(kind)")
        }
    }

    /// 画面のどの場面でも、英数字のセルは前景と背景が 4.5:1 以上（枠の線と記号は飾りなので除く。兄弟と同じ範囲）。
    @Test(arguments: Theme.catalog)
    func everyCharacterOnScreenIsReadable(_ theme: Theme) {
        let display = DisplayOptions(theme: theme, traits: TerminalTraits(frame: .boxDrawing, colors: .trueColor))
        for ticks in [0, 40, 400, 1_500, 4_000] {
            for pilot in [PilotLabel.autopilot(name: "BOLT.EXE"), .player(secondsLeft: 9)] {
                let state = ScreenRendererTests.state(
                    ScreenRendererTests.session(ticks: ticks), display: display, pilot: pilot, keys: .repeatOnly)
                let grid = ScreenRenderer.render(state, size: ScreenRendererTests.size)
                for row in 0..<grid.size.rows {
                    for column in 0..<grid.size.columns {
                        let cell = grid[column, row]
                        guard cell.character.isLetter || cell.character.isNumber else {
                            continue
                        }
                        #expect(
                            Contrast.ratio(cell.foreground, cell.background) >= 4.5,
                            "\(theme.name) tick \(ticks) (\(column), \(row)) '\(cell.character)'")
                    }
                }
            }
        }
    }

    static func distance(_ a: Rgb, _ b: Rgb) -> Int {
        abs(Int(a.red) - Int(b.red)) + abs(Int(a.green) - Int(b.green)) + abs(Int(a.blue) - Int(b.blue))
    }
}

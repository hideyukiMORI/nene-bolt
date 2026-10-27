import Testing

@testable import NeNeBoltTerminal

/// キーの読み取りと、押されているキー（FR-04b・ADR 0007）。
struct KeyTests {
    static func bytes(_ text: String) -> [UInt8] {
        Array(text.utf8)
    }

    /// win32-input-mode の 1 キーの列（仮想キー・走査コード・文字・押したか・修飾キー・回数）。
    static func win32(_ virtualKey: Int, _ character: Int, down: Bool, modifiers: Int = 0) -> String {
        "\u{1B}[\(virtualKey);0;\(character);\(down ? 1 : 0);\(modifiers);1_"
    }

    @Test func charactersAndArrowsArriveAsTypedKeys() {
        let decoding = KeyDecoder.decode(Self.bytes("zXq \u{1B}[C\u{1B}OA\u{1B}[D\u{1B}[Bk"))
        #expect(
            decoding.events == [
                .typed(.z), .typed(.x), .typed(.q), .typed(.space), .typed(.right), .typed(.up), .typed(.left),
                .typed(.down),
            ])
        #expect(!decoding.reportsReleases)
        #expect(KeyDecoder.decode(Self.bytes("tTdD")).events == [.typed(.t), .typed(.t), .typed(.d), .typed(.d)])
        #expect(KeyDecoder.decode([0x03]).events == [.typed(.interrupt)])
    }

    @Test func win32SequencesArriveAsPressAndRelease() {
        let text =
            Self.win32(0x27, 0, down: true) + Self.win32(0x5A, 122, down: true) + Self.win32(0x27, 0, down: false)
        let decoding = KeyDecoder.decode(Self.bytes(text))
        #expect(decoding.events == [.pressed(.right), .pressed(.z), .released(.right)])
        #expect(decoding.reportsReleases)
    }

    /// Shift 単独のような知らないキーの列は捨てるが、方式の証拠には数える。Ctrl+C はキーとして届く。
    @Test func win32UnknownKeysAreDroppedAndControlCQuits() {
        let shift = KeyDecoder.decode(Self.bytes(Self.win32(0x10, 0, down: true)))
        #expect(shift.events.isEmpty)
        #expect(shift.reportsReleases)
        #expect(
            KeyDecoder.decode(Self.bytes(Self.win32(0x43, 3, down: true, modifiers: 8))).events == [
                .pressed(.interrupt)
            ])
        #expect(KeyDecoder.decode(Self.bytes(Self.win32(0x51, 113, down: true))).events == [.pressed(.q)])
    }

    /// 列の途中で切れた入力や、知らない列で落ちない。
    @Test func brokenInputIsIgnored() {
        #expect(KeyDecoder.decode([0x1B]).events.isEmpty)
        #expect(KeyDecoder.decode(Self.bytes("\u{1B}[12;3R")).events.isEmpty)
        #expect(KeyDecoder.decode(Self.bytes("\u{1B}[39;0;0")).events.isEmpty)
    }

    @Test func pressAndReleaseHoldsUntilTheKeyIsReleased() {
        var held = HeldKeys()
        held.apply(.pressed(.right), at: 0)
        #expect(held.take(at: 10) == [.right])
        #expect(held.take(at: 500) == [.right])
        held.apply(.released(.right), at: 600)
        #expect(held.take(at: 610).isEmpty)
    }

    /// 離したことが届かなくても、くり返しが途絶えたら離したとみなす（窓の外へ注意が移ったとき）。
    @Test func aLostReleaseTimesOut() {
        var held = HeldKeys()
        held.apply(.pressed(.x), at: 0)
        #expect(held.take(at: HeldKeys.releaseTimeout - 1) == [.x])
        #expect(held.take(at: HeldKeys.releaseTimeout).isEmpty)
    }

    /// 1 刻みの間に押して離した短い打鍵も、次の 1 回は押されていたことにする。
    @Test func aTapBetweenTicksIsNotLost() {
        var held = HeldKeys()
        held.apply(.pressed(.z), at: 0)
        held.apply(.released(.z), at: 5)
        #expect(held.take(at: 20) == [.z])
        #expect(held.take(at: 50).isEmpty)
    }

    /// 簡易な方式: 最初の 1 文字は端末のくり返しが始まるまで押していることにし、くり返しが始まったら途絶えた時点で離す。
    @Test func repeatOnlyKeysAreHeldWhileTheRepeatKeepsComing() {
        var held = HeldKeys()
        held.apply(.typed(.left), at: 0)
        #expect(held.take(at: HeldKeys.firstRepeat - 1) == [.left])
        held.apply(.typed(.left), at: 500)
        held.apply(.typed(.left), at: 533)
        #expect(held.take(at: 533 + HeldKeys.repeatGap - 1) == [.left])
        #expect(held.take(at: 533 + HeldKeys.repeatGap).isEmpty)
    }

    @Test func aSingleTypedKeyIsReleasedAfterTheFirstRepeatWindow() {
        var held = HeldKeys()
        held.apply(.typed(.up), at: 1_000)
        _ = held.take(at: 1_001)
        #expect(held.take(at: 1_000 + HeldKeys.firstRepeat).isEmpty)
    }
}

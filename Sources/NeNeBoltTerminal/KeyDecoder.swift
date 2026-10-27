/// キー入力のバイト列をキーの出来事にする（FR-04b・ADR 0007）。
///
/// 2 つの方式を同じ経路で読む。
/// - 押す・離すを受け取る方式（Windows Terminal の win32-input-mode）: 1 キーの 1 回の出来事が
///   `ESC [ Vk ; Sc ; Uc ; Kd ; Cs ; Rc _`（仮想キー・走査コード・文字・押したか・修飾キー・回数）で届く
/// - 簡易な方式: 文字と矢印キーの列（`ESC [ A` 等）。離したことは届かない
///
/// 知らないキーと知らない列は捨てる。移植元の NeNe Swarm `KeyIntent`（コミット a660f47）の列の読み飛ばし方を引き継いだ。
public enum KeyDecoder {
    /// バイト列を読む。
    public static func decode(_ bytes: [UInt8]) -> KeyDecoding {
        var events: [KeyEvent] = []
        var reportsReleases = false
        var index = 0
        while index < bytes.count {
            let byte = bytes[index]
            guard byte == 0x1B else {
                if let key = character(UInt32(byte)) {
                    events.append(.typed(key))
                }
                index += 1
                continue
            }
            let end = sequenceEnd(bytes, from: index)
            let body = Array(bytes[min(index + 1, end)..<end])
            switch win32(body) {
            case .event(let event):
                reportsReleases = true
                events.append(event)
            case .unknownKey:
                reportsReleases = true
            case .other:
                if let key = arrow(body) {
                    events.append(.typed(key))
                }
            }
            index = end
        }
        return KeyDecoding(events: events, reportsReleases: reportsReleases)
    }

    /// `ESC` から始まる列の次の位置（`ESC [ … 終端` か `ESC O x`。`ESC` 単独なら 1 つ進める）。
    private static func sequenceEnd(_ bytes: [UInt8], from start: Int) -> Int {
        var index = start + 1
        guard index < bytes.count, bytes[index] == UInt8(ascii: "[") || bytes[index] == UInt8(ascii: "O") else {
            return index
        }
        index += 1
        while index < bytes.count, !(0x40...0x7E).contains(bytes[index]) {
            index += 1
        }
        return min(index + 1, bytes.count)
    }

    /// win32-input-mode の列（`[` から `_` まで）を読む。
    private static func win32(_ body: [UInt8]) -> Win32Read {
        guard body.count >= 2, body.first == UInt8(ascii: "["), body.last == UInt8(ascii: "_") else {
            return .other
        }
        let fields = String(decoding: body.dropFirst().dropLast(), as: UTF8.self)
            .split(separator: ";", omittingEmptySubsequences: false).map { Int($0) ?? 0 }
        let field = { (position: Int) in position < fields.count ? fields[position] : 0 }
        let (virtualKey, unicode, down, modifiers) = (field(0), field(2), field(3) != 0, field(4))
        let controlHeld = modifiers & 0x0C != 0
        let key: Key?
        if virtualKey == 0x43, controlHeld || unicode == 3 {
            key = .interrupt
        } else {
            key = arrowKey(virtualKey) ?? character(UInt32(max(unicode, 0)))
        }
        guard let key else {
            return .unknownKey
        }
        return .event(down ? .pressed(key) : .released(key))
    }

    /// 簡易な方式の矢印キー（`[A` 〜 `[D` か `OA` 〜 `OD`）。
    private static func arrow(_ body: [UInt8]) -> Key? {
        guard body.count == 2, body[0] == UInt8(ascii: "[") || body[0] == UInt8(ascii: "O") else {
            return nil
        }
        let final = body[1]
        if final == UInt8(ascii: "A") {
            return .up
        } else if final == UInt8(ascii: "B") {
            return .down
        } else if final == UInt8(ascii: "C") {
            return .right
        } else if final == UInt8(ascii: "D") {
            return .left
        }
        return nil
    }

    /// 仮想キーの矢印（VK_LEFT〜VK_DOWN = 0x25〜0x28）。
    private static func arrowKey(_ virtualKey: Int) -> Key? {
        if virtualKey == 0x25 {
            return .left
        } else if virtualKey == 0x26 {
            return .up
        } else if virtualKey == 0x27 {
            return .right
        } else if virtualKey == 0x28 {
            return .down
        }
        return nil
    }

    /// 文字のキー（大文字も同じ）。
    private static func character(_ code: UInt32) -> Key? {
        guard let scalar = Unicode.Scalar(code) else {
            return nil
        }
        let table: [(Character, Key)] = [
            ("z", .z), ("x", .x), (" ", .space), ("q", .q), ("t", .t), ("d", .d), ("\u{03}", .interrupt),
        ]
        let lowered = Character(scalar).lowercased()
        return table.first { String($0.0) == lowered }?.1
    }
}

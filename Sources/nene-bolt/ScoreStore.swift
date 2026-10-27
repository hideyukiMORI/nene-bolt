import Glibc
import NeNeBoltCore

/// ハイスコアのファイルの読み書き（FR-02g・ARC-009・ADR 0007）。ファイルに触れるのは合成ルートのここだけ。
///
/// 置き場は `$XDG_STATE_HOME/nene-bolt/highscores.txt`（無ければ `~/.local/state/nene-bolt/highscores.txt`）。
/// 書くときは一時ファイルに書いてから名前を替える（途中で落ちても前の表が残る）。
enum ScoreStore {
    /// 置き場のディレクトリ。環境変数から決まらなければ nil。
    static func directory() -> String? {
        if let raw = getenv("XDG_STATE_HOME"), raw.pointee != 0, raw.pointee == UInt8(ascii: "/") {
            return String(cString: raw) + "/nene-bolt"
        }
        guard let home = getenv("HOME"), home.pointee != 0 else {
            return nil
        }
        return String(cString: home) + "/.local/state/nene-bolt"
    }

    /// 表を読む。ファイルが無ければ空の表で、保存はできる。読めなければ起動中だけの記録にする。
    static func load() -> ScoreLoad {
        guard let directory = directory() else {
            return .memoryOnly
        }
        guard let file = fopen(directory + "/highscores.txt", "r") else {
            return errno == ENOENT ? .loaded(.empty) : .memoryOnly
        }
        defer { fclose(file) }
        var bytes: [UInt8] = []
        var buffer = [UInt8](repeating: 0, count: 4096)
        while bytes.count < 65_536 {
            let count = fread(&buffer, 1, buffer.count, file)
            if count == 0 {
                break
            }
            bytes += buffer.prefix(count)
        }
        switch HighScoreCodec.decode(String(decoding: bytes, as: UTF8.self)) {
        case .decoded(let table): return .loaded(table)
        case .rejected: return .memoryOnly
        }
    }

    /// 表を書く。書けたら true。
    static func save(_ table: HighScoreTable) -> Bool {
        guard let directory = directory(), makeDirectories(directory) else {
            return false
        }
        let path = directory + "/highscores.txt"
        let temporary = path + ".tmp"
        guard let file = fopen(temporary, "w") else {
            return false
        }
        let wrote = fputs(HighScoreCodec.encode(table), file) >= 0
        let closed = fclose(file) == 0
        return wrote && closed && rename(temporary, path) == 0
    }

    /// 置き場までのディレクトリを順に作る（既にあれば何もしない）。
    private static func makeDirectories(_ path: String) -> Bool {
        var current = ""
        for part in path.split(separator: "/") {
            current += "/" + part
            if mkdir(current, 0o755) != 0, errno != EEXIST {
                return false
            }
        }
        return true
    }
}

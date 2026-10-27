/// ランナーの性格（FR-04・FR-06・ADR 0008）。先の読み方・迷い・コインへの欲・体力の惜しみ方・撃ち方を数で持つ。
///
/// 名前は `ファイル名.拡張子` 風で、兄弟のキャスト（Gambit・Reversi・Igo・Poker・Swarm）と重ならない。
public struct Persona: Sendable, Hashable {
    /// 画面に出す名前。
    public let name: String
    /// 顔（ASCII）。
    public let face: String
    /// 何刻み先まで試すか。
    let horizon: Int
    /// 何刻みごとに選び直すか。
    let replan: Int
    /// 選び直すときに先を読まない確率（千分率）。読まないときは、ただ行き先へ走るか跳ぶ。
    let blindness: Int
    /// コインと拾うものの重み（百分率）。
    let greed: Int
    /// 体力を減らすことの重み（百分率）。
    let caution: Int
    /// 撃ち方。
    let trigger: Trigger
    /// 台本（1 人 50 本・FR-06）。
    let script: [ScriptLine]

    /// きっかけのセリフ。
    func lines(for cue: Cue) -> [String] {
        script.filter { $0.cue == cue }.map(\.text)
    }

    /// 4 名（毎ゲーム 1 名が走る）。
    public static let roster: [Persona] = [dash, hoard, patient, glitch]

    /// 走り屋。前しか見ず、コインに目もくれず、連射で押し通る。
    public static let dash = Persona(
        name: "DASH.EXE", face: "(>o>)", horizon: 24, replan: 3, blindness: 95, greed: 10, caution: 60,
        trigger: .rapid, script: dashScript)
    /// 集め屋。コインと拾うものを見ると寄り道する。
    public static let hoard = Persona(
        name: "HOARD.ZIP", face: "($_$)", horizon: 30, replan: 3, blindness: 80, greed: 300, caution: 100,
        trigger: .rapid, script: hoardScript)
    /// 慎重派。遠くまで読み、体力を惜しみ、溜め撃ちで片付けてから進む。
    public static let patient = Persona(
        name: "PATIENT.LOG", face: "(-.-)", horizon: 36, replan: 4, blindness: 45, greed: 60, caution: 250,
        trigger: .charge, script: patientScript)
    /// 壊れかけ。よく読み違え、体力を気にしない。
    public static let glitch = Persona(
        name: "GLITCH.DAT", face: "(@_@)", horizon: 18, replan: 3, blindness: 145, greed: 100, caution: 30,
        trigger: .rapid, script: glitchScript)
}

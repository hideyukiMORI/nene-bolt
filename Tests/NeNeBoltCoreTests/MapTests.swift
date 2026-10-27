import Testing

@testable import NeNeBoltCore

/// 4 つの面の地図（FR-02a・ADR 0005）。
@Suite struct MapTests {
    @Test(arguments: StageKind.allCases.indices)
    func everyStageMapReadsAndHasWhatItNeeds(_ index: Int) {
        let stage = Stage(number: index + 1)
        let map = StageCatalog.map(of: stage)
        #expect(map.columns == 180)
        #expect(map.spawns.filter { $0.kind == .start }.count == 1)
        #expect(map.first(.checkpoint) != nil)
        switch stage.kind {
        case .grassland, .cavern, .sky:
            #expect(map.first(.goal) != nil)
            #expect(map.first(.boss) == nil)
        case .fortress:
            #expect(map.first(.goal) == nil)
            #expect(map.first(.boss) != nil)
            #expect(map.first(.door) != nil)
        }
    }

    @Test func theCavernIsTallAndHasIceLaddersAndVanishingBlocks() {
        let map = StageCatalog.map(of: Stage(number: 2))
        #expect(map.rows == 30)
        var kinds: Set<String> = []
        for row in 0..<map.rows {
            for column in 0..<map.columns {
                switch map[column, row] {
                case .ice: kinds.insert("ice")
                case .ladder: kinds.insert("ladder")
                case .vanishing: kinds.insert("vanishing")
                case .empty, .solid, .spike, .conveyor: break
                }
            }
        }
        #expect(kinds == ["ice", "ladder", "vanishing"])
    }

    @Test func outsideTheMapIsWallOrPit() {
        let map = StageCatalog.map(of: Stage(number: 1))
        #expect(map[-1, 5] == .solid)
        #expect(map[map.columns, 5] == .solid)
        #expect(map[5, -1] == .solid)
        #expect(map[5, map.rows] == .empty)
    }

    @Test func charactersDecodeIntoTerrainAndSpawns() {
        guard case .decoded(let map) = StageMap.decode([["S#=H^1<>", "cwM     "]]) else {
            Issue.record("読めない")
            return
        }
        #expect(map[1, 0] == .solid)
        #expect(map[2, 0] == .ice)
        #expect(map[3, 0] == .ladder)
        #expect(map[4, 0] == .spike)
        #expect(map[5, 0] == .vanishing(group: 0))
        #expect(map[6, 0] == .conveyor(.left))
        #expect(map[7, 0] == .conveyor(.right))
        #expect(map.spawns.map(\.kind) == [.start, .coin, .walker, .mover])
        #expect(map[0, 0] == .empty)
    }

    @Test func pagesAreJoinedLeftToRight() {
        guard case .decoded(let map) = StageMap.decode([["S#", "##"], ["  ", "=="]]) else {
            Issue.record("読めない")
            return
        }
        #expect(map.columns == 4)
        #expect(map[3, 1] == .ice)
    }

    @Test func brokenMapsAreRejected() {
        #expect(StageMap.decode([["S#", "#"]]) == .rejected(.ragged(page: 0, row: 1)))
        #expect(StageMap.decode([["S?"]]) == .rejected(.unknownCharacter("?", column: 1, row: 0)))
        #expect(StageMap.decode([["##"]]) == .rejected(.starts(0)))
        #expect(StageMap.decode([["SS"]]) == .rejected(.starts(2)))
        #expect(StageMap.decode([["S"], ["#", "#"]]) == .rejected(.uneven))
    }
}

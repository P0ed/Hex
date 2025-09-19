import HexKit

@MainActor
extension Unit {

	private static var id = 0 as UnitID

	private static func nextID() -> UnitID {
		defer { id += 1 }
		return id
	}

	static func infantry(player: PlayerID, position: Hex) -> Self {
		.init(
			id: nextID(),
			player: player,
			position: position,
			hp: HP(10),
			atk: 4,
			def: 6,
			mov: 3
		)
	}
}

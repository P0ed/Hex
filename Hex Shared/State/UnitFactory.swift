@MainActor
private extension UnitID {

	private static var id = 0 as UnitID

	static func next() -> UnitID {
		defer { id.value += 1 }
		return id
	}
}

@MainActor
extension Unit {

	static func infantry(player: PlayerID, position: Hex) -> Self {
		.init(
			id: .next(),
			player: player,
			position: position,
			hp: HP(10),
			stats: Stats(
				atk: 4,
				def: 6,
				mov: 3
			)
		)
	}
}

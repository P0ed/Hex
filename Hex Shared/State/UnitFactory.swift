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
			stats: .make { stats in
				stats.atk = 4
				stats.def = 6
				stats.mov = 3
				stats.rng = 1
				stats.unitType = .inf
			}
		)
	}

	static func tank(player: PlayerID, position: Hex) -> Self {
		.init(
			id: .next(),
			player: player,
			position: position,
			stats: .make { stats in
				stats.atk = 7
				stats.def = 10
				stats.mov = 5
				stats.rng = 2
				stats.armor = 2
				stats.unitType = .tank
			}
		)
	}

	static func art(player: PlayerID, position: Hex) -> Self {
		.init(
			id: .next(),
			player: player,
			position: position,
			stats: .make { stats in
				stats.atk = 6
				stats.def = 4
				stats.mov = 1
				stats.rng = 4
				stats.unitType = .art
			}
		)
	}
}

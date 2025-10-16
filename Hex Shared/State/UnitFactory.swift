@MainActor
extension UnitID {

	private static var id = 0 as UnitID

	static func next() -> UnitID {
		id.value += 1
		return id
	}
}

@MainActor
extension Unit {

	static func infantry(id: UnitID? = nil, player: PlayerID, position: Hex) -> Self {
		.init(
			id: id ?? .next(),
			player: player,
			position: position,
			stats: .base >< .inf39
		)
	}

	static func tank(id: UnitID? = nil, player: PlayerID, position: Hex) -> Self {
		.init(
			id: id ?? .next(),
			player: player,
			position: position,
			stats: .base >< .tank39
		)
	}

	static func art(id: UnitID? = nil, player: PlayerID, position: Hex) -> Self {
		.init(
			id: id ?? .next(),
			player: player,
			position: position,
			stats: .base >< .art39
		)
	}
}

extension Stats {

	static var inf39: Self {
		.make { stats in
			stats.atk = 4
			stats.def = 6
			stats.mov = 3
			stats.rng = 1
			stats.unitType = .inf
		}
	}

	static var tank39: Self {
		.make { stats in
			stats.atk = 7
			stats.def = 10
			stats.mov = 5
			stats.rng = 2
			stats.armor = 2
			stats.unitType = .tank
		}
	}

	static var art39: Self {
		.make { stats in
			stats.atk = 6
			stats.def = 4
			stats.mov = 1
			stats.rng = 4
			stats.unitType = .art
		}
	}
}

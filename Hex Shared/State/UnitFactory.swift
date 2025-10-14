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
			stats: Stats(
				atk: 4,
				def: 6,
				mov: 3,
				rng: 1,
				flg: .empty
			)
		)
	}

	static func tank(player: PlayerID, position: Hex) -> Self {
		.init(
			id: .next(),
			player: player,
			position: position,
			stats: Stats(
				atk: 7,
				def: 10,
				mov: 5,
				rng: 2,
				flg: .make { flg in
					flg.armor = 2
				}
			)
		)
	}

	static func art(player: PlayerID, position: Hex) -> Self {
		.init(
			id: .next(),
			player: player,
			position: position,
			stats: Stats(
				atk: 6,
				def: 4,
				mov: 1,
				rng: 4,
				flg: .make { flg in
					flg.isArty = true
				}
			)
		)
	}
}

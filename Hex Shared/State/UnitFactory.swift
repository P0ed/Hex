@MainActor
extension UnitID {

	private(set) static var next: UnitID = 0

	static func make() -> UnitID {
		defer { next.value += 1 }
		return next
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
			stats.hardAttack = 1
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

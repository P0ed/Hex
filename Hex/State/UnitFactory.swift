@MainActor
extension UnitID {

	private(set) static var next: UnitID = 0

	static func make() -> UnitID {
		defer { next.value += 1 }
		return next
	}
}

extension Stats {

	static var inf: Self {
		.make { stats in
			stats.atk = 4
			stats.def = 6
			stats.mov = 3
			stats.rng = 1
			stats.unitType = .inf
			stats.moveType = .leg
		}
	}

	static var tank: Self {
		.make { stats in
			stats.atk = 7
			stats.def = 9
			stats.mov = 5
			stats.rng = 2
			stats.armor = 2
			stats.hardAttack = 1
			stats.unitType = .tank
			stats.moveType = .track
		}
	}

	static var art: Self {
		.make { stats in
			stats.atk = 6
			stats.def = 4
			stats.mov = 1
			stats.rng = 4
			stats.unitType = .art
			stats.moveType = .leg
		}
	}

	static var recon: Self {
		.make { stats in
			stats.atk = 3
			stats.def = 4
			stats.armor = 1
			stats.mov = 6
			stats.rng = 1
			stats.unitType = .recon
			stats.moveType = .track
		}
	}
}

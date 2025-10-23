@MainActor
extension UnitID {

	private(set) static var next: UnitID = 0

	static func make() -> UnitID {
		defer { next.rawValue += 1 }
		return next
	}
}

extension Stats {

	static var base: Self {
		.make { stats in
			stats.hp = 15
			stats.mp = 1
			stats.ap = 1
			stats.ammo = 15
			stats.fuel = 15
		}
	}

	static var shop: Self {
		modifying(.base) { stats in
			stats.mp = 0
			stats.ap = 0
		}
	}

	static var builder: Self {
		.make { stats in
			stats.mov = 5
			stats.unitType = .engineer
			stats.moveType = .wheel
		}
	}

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
			stats.rng = 1
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
			stats.rng = 3
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

	static var radar: Self {
		.make { stats in
			stats.armor = 1
			stats.unitType = .building
		}
	}

	static var bunker: Self {
		.make { stats in
			stats.armor = 1
			stats.unitType = .building
		}
	}
}

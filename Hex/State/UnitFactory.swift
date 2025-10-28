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

	static var veteran: Self {
		.make { stats in stats.exp = 0x10 }
	}

	static var elite: Self {
		.make { stats in stats.exp = 0x20 }
	}

	static var builder: Self {
		.make { stats in
			stats.unitType = .engineer
			stats.mov = 5
			stats.moveType = .wheel
		}
	}

	static var truck: Self {
		.make { stats in
			stats.unitType = .supply
			stats.def = 2
			stats.mov = 5
			stats.moveType = .wheel
		}
	}

	static var inf: Self {
		.make { stats in
			stats.unitType = .inf
			stats.atk = 4
			stats.def = 6
			stats.mov = 3
			stats.rng = 1
			stats.moveType = .leg
		}
	}

	static var tank: Self {
		.make { stats in
			stats.unitType = .tank
			stats.atk = 7
			stats.def = 9
			stats.mov = 5
			stats.rng = 1
			stats.armor = 2
			stats.hardAttack = 1
			stats.moveType = .track
		}
	}

	static var art: Self {
		.make { stats in
			stats.unitType = .art
			stats.atk = 6
			stats.def = 4
			stats.mov = 1
			stats.rng = 3
			stats.moveType = .leg
		}
	}

	static var recon: Self {
		.make { stats in
			stats.unitType = .recon
			stats.atk = 3
			stats.def = 5
			stats.armor = 1
			stats.mov = 6
			stats.rng = 1
			stats.moveType = .track
		}
	}
}

extension Stats {

	static var base: Self {
		.make { stats in
			stats.hp = 0xF
			stats.mp = 0x1
			stats.ap = 0x1
			stats.ammo = 0xF
			stats.fuel = 0xF
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

	static var t72: Self {
		.make { stats in
			stats.unitType = .tank
			stats.atk = 8
			stats.def = 7
			stats.mov = 6
			stats.rng = 1
			stats.armor = 3
			stats.hardAttack = 3
			stats.moveType = .track
		}
	}

	static var m1A2: Self {
		.make { stats in
			stats.unitType = .tank
			stats.atk = 10
			stats.def = 9
			stats.mov = 6
			stats.rng = 1
			stats.armor = 3
			stats.hardAttack = 3
			stats.moveType = .track
		}
	}

	static var strv122: Self {
		.make { stats in
			stats.unitType = .tank
			stats.atk = 9
			stats.def = 10
			stats.mov = 6
			stats.rng = 1
			stats.armor = 3
			stats.hardAttack = 3
			stats.moveType = .track
		}
	}

	static var strf90: Self {
		.make { stats in
			stats.unitType = .tank
			stats.atk = 8
			stats.def = 9
			stats.mov = 7
			stats.rng = 1
			stats.armor = 2
			stats.hardAttack = 2
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
			stats.atk = 4
			stats.def = 5
			stats.armor = 1
			stats.mov = 7
			stats.rng = 1
			stats.moveType = .track
		}
	}
}

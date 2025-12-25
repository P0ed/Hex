extension Stats {

	static var base: Self {
		.make { stats in
			stats.hp = 0xF
			stats.mp = 0x1
			stats.ap = 0x1
			stats.ammo = 0xF
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
			stats.unitType = .ifv
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
			stats.unitType = .ifv
			stats.atk = 4
			stats.def = 5
			stats.armor = 1
			stats.mov = 7
			stats.rng = 1
			stats.moveType = .track
		}
	}

	static func ifv(_ country: Country) -> Self {
		switch country.team {
		case .axis: .strf90
		case .allies, .soviet: .recon
		}
	}

	static func tank(_ country: Country) -> Self {
		switch country {
		case .ukr, .swe: .strv122
		case .usa, .isr: .m1A2
		case .rus, .irn, .dnr, .lnr: .t72
		}
	}

	static var mh6: Self {
		.make { stats in
			stats.unitType = .air
			stats.atk = 6
			stats.def = 7
			stats.moveType = .air
			stats.mov = 9
			stats.rng = 1
		}
	}

	static func heli(_ country: Country) -> Self {
		switch country.team {
		default: .mh6
		}
	}
}

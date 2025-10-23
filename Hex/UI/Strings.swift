extension Unit {

	var status: String {
		.makeStatus { add in
			add("\(stats.unitType)")
			add(stats.atk > 0 ? "ammo: \(stats.ammo)" : "")
			add(stats.moveType != .leg ? "fuel: \(stats.fuel)" : "")
		}
	}

	var description: String {
		"""
		\(stats.unitType)
		
		ATK: \(stats.atk) - \(stats.hardAttack)
		DEF: \(stats.def) - \(stats.armor)
		MOV: \(stats.mov) - \(stats.moveType)
		RNG: \(stats.rng)
		
		
		
		- - - - - - - -
		Cost: \(cost)
		"""
	}
}

extension GameState {

	var statusText: String {
		if let selectedUnit, let unit = self[selectedUnit] {
			unit.status
		} else if let building = buildings[cursor] {
			.makeStatus { add in
				add("\(building.type)")
				add("controller: \(building.player.team)")
			}
		} else {
			"\(map[cursor])"
		}
	}
}

extension MenuState {

	var statusText: String { items[cursor].text }
}

extension String {

	mutating func pad(to length: Int) {
		let dlen = length - count
		if dlen > 0 {
			self += .init(repeating: " ", count: dlen)
		}
	}

	static func makeStatus(pad: Int = 12, mk: ((String) -> Void) -> Void) -> String {
		.make { str in
			var padding = 0

			func add(_ s: String) {
				str += s
				padding += pad
				str.pad(to: padding)
			}

			mk(add)
		}
	}
}

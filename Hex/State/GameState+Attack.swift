extension GameState {

	func targets(unit: Unit) -> [Unit] {
		!unit.canAttack ? [] : enemyUnits.filter { u in
			visible.contains(u.position) && unit.canHit(unit: u)
		}
	}

	func artSupport(for defender: Ref<Unit>, attacker: Ref<Unit>) -> Ref<Unit>? {
		units[attacker].stats.unitType == .art
		? nil
		: units[defender].position.neighbors.firstMap { hx in
			units[hx].flatMap { ref in
				let u = units[ref]

				return u.country.team == units[defender].country.team
				&& u.stats.unitType == .art
				&& u.canHit(unit: units[attacker])
				? ref : nil
			}
		}
	}

	mutating func fire(src: Ref<Unit>, dst: Ref<Unit>, defBonus: UInt8 = 0) {
		let atk = Int(units[src].stats.atk + units[src].stats.stars)
		let def = Int(units[dst].stats.def + units[dst].stats.stars + defBonus)

		let dmg = UInt8(atk - def > 0 ? atk : atk / 2)

		let hpLeft = units[dst].stats.hp.decrement(by: dmg)
		units[dst].stats.ent.decrement()

		units[src].stats.ammo.decrement()
		units[src].stats.exp.increment(by: hpLeft != 0 ? dmg : dmg + 4)

		events.append(.attack(units[src].id, units[dst]))
	}

	mutating func attack(src: Ref<Unit>, dst: Ref<Unit>) {
		guard units[src].country == country,
			  units[src].country.team != units[dst].country.team,
			  units[src].canAttack, units[src].canHit(unit: units[dst])
		else { return }

		if let art = artSupport(for: dst, attacker: src) {
			fire(src: art, dst: src)
		}
		if units[src].alive {
			let defBonus = units[dst].stats.ent + map[units[dst].position].defBonus
			fire(src: src, dst: dst, defBonus: defBonus)
			units[src].stats.ap.decrement()
		}
		if units[dst].alive, units[src].alive,
		   units[dst].canHit(unit: units[src]),
		   units[src].stats.unitType != .art {

			fire(src: dst, dst: src)
		}

		selectUnit(units[src].hasActions && units[src].alive ? units[src].id : .none)

		if !units[src].alive {
			units.fastRemove(at: src.index)
		} else if !units[dst].alive {
			units.fastRemove(at: dst.index)
		}
	}
}

extension TacticalState {

	func targets(unit: Unit) -> [(UID, Unit)] {
		!unit.canAttack ? [] : units.compactMap { i, u in
			u.country.team != unit.country.team
			&& player.visible[u.position]
			&& unit.canHit(unit: u)
			? (i, u) : nil
		}
	}

	func artSupport(for defender: UID, attacker: UID) -> UID? {
		units[attacker].stats.unitType == .art
		? nil
		: units[defender].position.n8.firstMap { hx in
			units[hx].flatMap { i, u in
				u.country.team == units[defender].country.team
				&& u.stats.unitType == .art
				&& u.canHit(unit: units[attacker])
				? i : nil
			}
		}
	}

	mutating func fire(src: UID, dst: UID, defBonus: UInt8 = 0) {
		let atk = Int(units[src].stats.atk + units[src].stats.stars)
		let def = Int(units[dst].stats.def + units[dst].stats.stars + defBonus)

		let dif = atk - def
		let t1 = max(1, 6 - dif)
		let t2 = t1 + 2
		let t3 = t2 + 3
		let t4 = t3 + 4
		let rounds = units[src].stats.hp / 2 + 1

		let dmg = UInt8((0 ..< rounds).reduce(into: 0) { r, _ in
			let d = d20(.min(2))
			r +=
			d > t4 ? 4 :
			d > t3 ? 3 :
			d > t2 ? 2 :
			d > t1 ? 1 :
			0
		})

		let hpLeft = units[dst].stats.hp.decrement(by: dmg)
		units[dst].stats.ent.decrement()

		units[src].stats.ammo.decrement()
		units[src].stats.exp.increment(by: hpLeft != 0 ? dmg : dmg * 2)

		camera = units[dst].position
		events.add(.attack(src, dst, units[dst]))
	}

	mutating func attack(src: UID, dst: UID) {
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

		selectUnit(units[src].alive && units[src].hasActions ? src : .none)
	}
}

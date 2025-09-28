extension State {

	func moves(for unit: Unit) -> Set<Hex> {
		Set([Hex].make { hs in
			hs += unit.position.circle(Int(unit.stats.mov))
		})
		.subtracting(units.map(\.position))
	}

	func vision(for unit: Unit) -> Set<Hex> {
		Set(unit.position.circle(2))
	}

	mutating func endTurn() {
		guard let idx = players.firstIndex(where: { $0.id == currentPlayer }) else { return }

		let nextIdx = (idx + 1) % players.count
		currentPlayer = players[nextIdx].id
		turn = nextIdx == 0 ? turn + 1 : turn
		selectUnit(.none)

		if nextIdx == 0 {
			units = units.mapInPlace { u in
				u.nextTurn()
			}
		}
	}

	mutating func move(unit: Unit, to position: Hex) {
		guard unit.canMove, moves(for: unit).contains(position) else { return }

		let unit = modifying(unit) { u in
			u.position = position
			u.mp.decrement()
		}
		self[unit.id] = unit
		selectUnit(unit.hasActions ? unit : .none)
		events.append(.move(unit.id))
	}

	mutating func attack(src: Unit, dst: Unit) {
		guard src.canFire, src.canHit(unit: dst) else { return }

		var src = src
		var dst = dst

		src.fired = true
		src.ammo.decrement()
		dst.hp.decrement(amount: src.stats.atk)

		if !dst.hp.isEmpty, !dst.ammo.isEmpty, dst.canHit(unit: src) {
			dst.ammo.decrement()
			src.hp.decrement(amount: dst.stats.atk)
		}

		self[src.id] = src.hp.isEmpty ? .none : src
		self[dst.id] = dst.hp.isEmpty ? .none : dst

		selectUnit(src.hasActions && !src.hp.isEmpty ? src : .none)
		events.append(.attack(src.id, dst.id))
		if dst.hp.isEmpty { events.append(.kill(dst.id)) }
		if src.hp.isEmpty { events.append(.kill(src.id)) }
	}
}

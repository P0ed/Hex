extension State {

	func moves(for unit: Unit) -> Set<Hex> {
		.make { hs in
			if unit.stats.typ == .air {
				hs.formUnion(unit.position.circle(Int(unit.stats.mov)))
			} else {
				var front = [(unit.position, Int(unit.stats.mov))] as [(Hex, Int)]
				repeat {
					front = front.flatMap { fx, mp in
						fx.circle(1).compactMap { hx in
							let mpLeft = mp - map[hx].moveCost
							return hs.contains(hx) || mpLeft < 0
							? nil
							: (hx, mpLeft)
						}
					}
					hs.formUnion(front.map(\.0))
				} while !front.isEmpty
			}
		}
		.subtracting(units.map(\.position))
	}

	func vision(for unit: Unit) -> Set<Hex> {
		Set(unit.position.circle(2))
	}

	func vision(for player: PlayerID) -> Set<Hex> {
		units.reduce(into: [] as Set<Hex>) { v, u in
			guard u.player == player else { return }
			v.formUnion(vision(for: u))
		}
	}

	mutating func initialize() {
		visible = vision(for: currentPlayer)
		events = units.map { u in .spawn(u.id) }
	}

	mutating func endTurn() {
		guard let idx = players.firstIndex(where: { $0.id == currentPlayer }) else { return }

		let nextIdx = (idx + 1) % players.count
		currentPlayer = players[nextIdx].id
		turn = nextIdx == 0 ? turn + 1 : turn
		selectUnit(.none)

		visible = vision(for: currentPlayer)

		if nextIdx == 0 {
			units = units.mapInPlace { u in
				u.nextTurn()
			}
		}
	}

	mutating func selectUnit(_ unit: Unit?) {
		if let unit {
			selectedUnit = unit.id
			cursor = unit.position
			selectable = unit.canMove ? moves(for: unit) : .none
		} else {
			selectedUnit = .none
			selectable = .none
		}
	}

	mutating func move(unit: Unit, to position: Hex) {
		guard unit.player == currentPlayer,
			  unit.canMove, moves(for: unit).contains(position)
		else { return }

		let unit = modifying(unit) { u in
			u.position = position
			u.mp.decrement()
		}
		self[unit.id] = unit
		let vision = vision(for: unit)
		visible?.formUnion(vision)
		selectUnit(unit.hasActions ? unit : .none)
		events.append(.move(unit.id))
	}

	mutating func attack(src: Unit, dst: Unit) {
		guard src.player == currentPlayer,
			  src.player.team != dst.player.team,
			  src.canFire, src.canHit(unit: dst)
		else { return }

		var src = src
		var dst = dst

		src.fired = true
		src.ammo.decrement()
		dst.hp.decrement(by: src.stats.atk)

		if dst.hp > 0, dst.ammo > 0, dst.canHit(unit: src) {
			dst.ammo.decrement()
			src.hp.decrement(by: dst.stats.atk)
		}

		self[src.id] = src.hp == 0 ? .none : src
		self[dst.id] = dst.hp == 0 ? .none : dst

		selectUnit(src.hasActions && src.hp > 0 ? src : .none)
		events.append(.attack(src.id, dst.id))
		if dst.hp == 0 { events.append(.kill(dst.id)) }
		if src.hp == 0 { events.append(.kill(src.id)) }
	}
}

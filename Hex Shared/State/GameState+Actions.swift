extension GameState {

	var prestige: UInt16 {
		get { self[currentPlayer]?.prestige ?? 0 }
		set { self[currentPlayer]?.prestige = newValue }
	}

	var income: UInt16 {
		min(.max - prestige, map.cities.values.reduce(into: 0) { r, c in
			r += c.controller == currentPlayer ? 48 : 0
		})
	}

	func moves(for unit: Unit) -> Set<Hex> {
		.make { hs in
			if unit.stats.unitType == .air {
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
		.union(map.cities.flatMap { hex, city in
			city.controller == player ? hex.circle(1) : []
		})
	}

	mutating func initialize() {
		visible = vision(for: currentPlayer)
		events = units.map { u in .spawn(u.id) }
	}

	mutating func endTurn() {
		guard let idx = players.firstIndex(where: { p in p.id == currentPlayer })
		else { return }

		players[idx].prestige += income
		captureCities()

		let nextIdx = (idx + 1) % players.count
		currentPlayer = players[nextIdx].id
		turn = nextIdx == 0 ? turn + 1 : turn
		selectUnit(.none)

		visible = vision(for: currentPlayer)

		if nextIdx == 0 {
			units = units.mapInPlace { u in u.nextTurn() }
		}
	}

	private mutating func captureCities() {
		let reflag = units.reduce(into: false) { reflag, u in
			if let city = map.cities[u.position], city.controller != u.player {
				map.cities[u.position]?.controller = u.player
				reflag = true
			}
		}
		if reflag {
			events.append(.reflag)
			eliminatePlayers()
		}
	}

	private mutating func eliminatePlayers() {
		players.removeAll { player in
			!map.cities.values.contains { city in
				city.controller == player.id
			}
		}
		if players.count == 1 {
			events.append(.gameOver)
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
			u.stats.mp.decrement()
		}
		self[unit.id] = unit
		let vision = vision(for: unit)
		visible.formUnion(vision)
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

		src.stats.ap.decrement()
		src.stats.ammo.decrement()
		dst.stats.hp.decrement(by: src.stats.atk)

		if dst.stats.hp > 0, dst.stats.ammo > 0, dst.canHit(unit: src) {
			dst.stats.ammo.decrement()
			src.stats.hp.decrement(by: dst.stats.atk)
		}

		self[src.id] = src.stats.hp == 0 ? .none : src
		self[dst.id] = dst.stats.hp == 0 ? .none : dst

		selectUnit(src.hasActions && src.stats.hp > 0 ? src : .none)
		events.append(.attack(src.id, dst.id))

		if src.stats.hp == 0 { events.append(.kill(src.id)) }
		if dst.stats.hp == 0 { events.append(.kill(dst.id)) }
	}

	private var tooFarX: Bool { abs(camera.pt.x - cursor.pt.x) > 16.0 }
	private var tooFarY: Bool { abs(camera.pt.y - cursor.pt.y) > 9.0 }

	var isCursorTooFar: Bool { tooFarX || tooFarY }

	mutating func alignCamera() {
		while tooFarX {
			camera = camera.neighbor((camera.pt.x - cursor.pt.x) > 0.0 ? .left : .right)
		}
		while tooFarY {
			camera = camera.neighbor((camera.pt.y - cursor.pt.y) > 0.0 ? .down : .up)
		}
	}
}

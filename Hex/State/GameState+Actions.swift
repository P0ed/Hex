extension GameState {

	var prestige: UInt16 {
		get { self[player]?.prestige ?? 0 }
		set { self[player]?.prestige = newValue }
	}

	var income: UInt16 {
		min(.max - prestige, map.cities.values.reduce(into: 0) { r, c in
			r += c.controller == player ? 48 : 0
		})
	}

	func moves(for unit: Unit) -> Set<Hex> {
		.make { hxs in
			var front = [(unit.position, unit.stats.mov)]
			repeat {
				front = front.flatMap { fx, mp in
					fx.circle(1).compactMap { hx in
						let moveCost = map[hx].moveCost(unit.stats)
						return !hxs.contains(hx) && moveCost <= mp
						? (hx, mp - moveCost)
						: .none
					}
				}
				hxs.formUnion(front.map(\.0))
			} while !front.isEmpty
		}
		.subtracting(units.map(\.position))
	}

	func vision(for unit: Unit) -> Set<Hex> {
		let range = switch unit.stats.unitType {
		case .recon: 3
		case .inf, .tank, .air: 2
		default: 1
		}
		return Set(unit.position.circle(range))
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
		players = players.mapInPlace { p in p.visible = vision(for: p.id) }
		events = units.map { u in .spawn(u.id) }
	}

	mutating func endTurn() {
		guard let idx = players.firstIndex(where: { p in p.id == player })
		else { return }

		players[idx].prestige += income
		captureCities()

		let nextIdx = (idx + 1) % players.count
		player = players[nextIdx].id
		turn = nextIdx == 0 ? turn + 1 : turn
		selectUnit(.none)

		if nextIdx == 0 {
			players = players.mapInPlace { p in p.visible = vision(for: p.id) }
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
		if Set(players.map(\.id.team)).count == 1 {
			events.append(.gameOver)
		}
	}

	mutating func selectUnit(_ uid: UnitID?) {
		if let uid, let unit = self[uid] {
			selectedUnit = unit.id
			cursor = unit.position
			selectable = unit.canMove ? moves(for: unit) : .none
		} else {
			selectedUnit = .none
			selectable = .none
		}
	}

	mutating func move(unit: UnitID, to position: Hex) {
		guard var unit = self[unit],
			  unit.player == player,
			  unit.canMove, moves(for: unit).contains(position)
		else { return }

		unit.position = position
		unit.stats.mp.decrement()

		self[unit.id] = unit
		let vision = vision(for: unit)
		self[player]?.visible.formUnion(vision)
		selectUnit(unit.hasActions ? unit.id : .none)
		events.append(.move(unit.id))
	}

	func targets(unit: UnitID) -> [Unit] {
		self[unit].map { u in
			enemyUnits
				.filter { u in visible.contains(u.position) }
				.filter(u.canHit)
		} ?? []
	}

	mutating func damage(atk: UInt8, def: UInt8) -> UInt8 {
		let dif = Int(atk) - Int(def)
		
		return dif > 0 ? atk : atk / 2
	}

	mutating func attack(src: UnitID, dst: UnitID) {
		guard var src = self[src], var dst = self[dst],
			  src.player == player,
			  src.player.team != dst.player.team,
			  src.canFire, src.canHit(unit: dst)
		else { return }

		let terrainDef = map[dst.position].defBonus
		let dmg = damage(atk: src.stats.atk, def: dst.stats.def + dst.stats.ent + terrainDef)
		dst.stats.hp.decrement(by: dmg)
		dst.stats.ent.decrement()
		src.stats.ap.decrement()
		src.stats.ammo.decrement()

		if dst.stats.hp > 0, dst.canHit(unit: src), src.stats.unitType != .art {
			let dmg = damage(atk: dst.stats.atk, def: src.stats.def)
			src.stats.hp.decrement(by: dmg)
			dst.stats.ammo.decrement()
		}

		self[src.id] = src.stats.hp == 0 ? .none : src
		self[dst.id] = dst.stats.hp == 0 ? .none : dst

		selectUnit(src.hasActions && src.stats.hp > 0 ? src.id : .none)
		events.append(.attack(src.id, dst.id))

		if src.stats.hp == 0 { events.append(.kill(src.id)) }
		if dst.stats.hp == 0 { events.append(.kill(dst.id)) }
	}

	private var tooFarX: Bool { abs(camera.pt.x - cursor.pt.x) > 9.0 * scale }
	private var tooFarY: Bool { abs(camera.pt.y - cursor.pt.y) > 5.0 * scale }

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

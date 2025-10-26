extension GameState {

	var prestige: UInt16 {
		get { players[player].prestige }
		set { players[player].prestige = newValue }
	}

	var income: UInt16 {
		min(.max - prestige, buildings.reduce(into: 0) { r, c in
			r += c.player == player ? 48 : 0
		})
	}

	mutating func initialize() {
		players = players.mapInPlace { p in p.visible = vision(for: p.id) }
		events = units.map { u in .spawn(u.id) }
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
			if u.player == player { v.formUnion(vision(for: u)) }
		}
		.union(buildings.flatMap { building in
			building.player == player ? building.position.circle(1) : []
		})
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

			let idx = buildings.firstIndex { b in b.position == u.position }

			if let idx, buildings[idx].player.team != u.player.team {
				buildings[idx].player = u.player
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
			!buildings.contains { building in
				building.type == .city && building.player == player.id
			}
		}
		if Set(players.map(\.id.team)).count == 1 {
			events.append(.gameOver)
		}
	}

	mutating func selectUnit(_ uid: UnitID?) {
		if let uid {
			let unitRef = units[uid]
			let unit = units[unitRef]
			selectedUnit = unit.id
			cursor = unit.position
			selectable = unit.canMove ? moves(for: unit) : .none
		} else {
			selectedUnit = .none
			selectable = .none
		}
	}

	func moves(for unit: Unit) -> Set<Hex> {
		!unit.canMove ? [] : .make { hxs in
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

	mutating func move(unit: UnitID, to position: Hex) {
		let unitRef = units[unit]
		var unit = units[unitRef]

		guard unit.player == player,
			  unit.canMove, moves(for: unit).contains(position)
		else { return }

		unit.position = position
		unit.stats.mp = 0
		unit.stats.ent = 0
		if unit.stats.unitType == .art { unit.stats.ap = 0 }

		units[unitRef] = unit
		let vision = vision(for: unit)
		players[player].visible.formUnion(vision)
		selectUnit(unit.hasActions ? unit.id : .none)
		events.append(.move(unit.id))
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

	var unitMenuActions: [MenuItem] {
		if let selectedUnit {
			[
				.init(icon: "Reinforce", text: "Reinforce", action: { state in
					state.units[state.units[selectedUnit]].reinforce()
					state.events.append(.update(selectedUnit))
				}),
				.init(icon: "Refuel", text: "Resupply", action: { state in
					state.units[state.units[selectedUnit]].resupply()
				}),
			]
		} else {
			[]
		}
	}
}

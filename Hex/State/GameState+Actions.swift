extension GameState {

	func vision(for unit: Unit) -> Set<Hex> {
		let range = switch unit.stats.unitType {
		case .recon: 3
		case .inf, .tank, .air: 2
		default: 1
		}
		return Set(unit.position.circle(range))
	}

	func vision(for country: Country) -> Set<Hex> {
		units.reduce(into: [] as Set<Hex>) { v, u in
			if u.country == country { v.formUnion(vision(for: u)) }
		}
		.union(buildings.flatMap { building in
			building.country == country ? building.position.circle(1) : []
		})
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
		let ref = units[unit]

		guard units[ref].country == country,
			  units[ref].canMove, moves(for: units[ref]).contains(position)
		else { return }

		let distance = units[ref].position.distance(to: position)
		units[ref].position = position
		units[ref].stats.mp = 0
		units[ref].stats.ent = 0
		if units[ref].stats.unitType == .art { units[ref].stats.ap = 0 }

		let vision = vision(for: units[ref])
		player.visible.formUnion(vision)
		selectUnit(units[ref].hasActions ? units[ref].id : .none)
		events.append(.move(units[ref].id, distance))
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

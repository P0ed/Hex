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
		units.reduce(into: [] as Set<Hex>) { v, i, u in
			if u.country == country { v.formUnion(vision(for: u)) }
		}
		.union(buildings.flatMap { building in
			building.country == country ? building.position.circle(1) : []
		})
	}

	mutating func selectUnit(_ uid: UID?) {
		if let uid {
			selectedUnit = uid
			cursor = units[uid].position
			selectable = units[uid].canMove ? moves(for: units[uid]) : .none
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
				hxs.formUnion(front.map { pos, _ in pos })
			} while !front.isEmpty
		}
		.subtracting(units.map { _, u in u.position })
	}

	mutating func move(unit uid: UID, to position: Hex) {
		guard units[uid].alive, units[uid].country == country,
			  units[uid].canMove, moves(for: units[uid]).contains(position)
		else { return }

		let distance = units[uid].position.distance(to: position)
		units[uid].position = position
		units[uid].stats.mp = 0
		units[uid].stats.ent = 0
		if units[uid].stats.unitType == .art { units[uid].stats.ap = 0 }

		let vision = vision(for: units[uid])
		player.visible.formUnion(vision)
		selectUnit(units[uid].hasActions ? uid : .none)
		events.append(.move(uid, distance))
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

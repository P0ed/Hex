import CoreGraphics

extension GameState {

	func vision(for unit: Unit) -> Set<XY> {
		let range = switch unit.stats.unitType {
		case .recon: 3
		case .inf, .tank, .air: 2
		default: 1
		}
		return Set(unit.position.circle(range * 3))
	}

	func vision(for country: Country) -> Set<XY> {
		units.reduce(into: [] as Set<XY>) { v, i, u in
			if u.country == country { v.formUnion(vision(for: u)) }
		}
		.union(buildings.flatMap { building in
			building.country == country ? building.position.circle(3) : []
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

	func moves(for unit: Unit) -> Set<XY> {
		!unit.canMove ? [] : .make { xys in
			var front = [(unit.position, unit.stats.mov)]
			repeat {
				front = front.flatMap { xy, mp in
					xy.n8.compactMap { xy in
						let moveCost = map[xy].moveCost(unit.stats)
						return !xys.contains(xy) && moveCost <= mp
						? (xy, mp - moveCost)
						: .none
					}
				}
				xys.formUnion(front.map { pos, _ in pos })
			} while !front.isEmpty
		}
		.subtracting(units.map { _, u in u.position })
	}

	mutating func move(unit uid: UID, to position: XY) {
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

	private var tooFarX: Bool { abs(camera.pt.x - cursor.pt.x) > 4.0 * scale }
	private var tooFarY: Bool { abs(camera.pt.y - cursor.pt.y) > 4.0 * scale }

	var isCursorTooFar: Bool { tooFarX || tooFarY }

	mutating func alignCamera() {
		while tooFarX {
			camera = camera.n8[(camera.pt.x - cursor.pt.x) > 0.0 ? 5 : 1]
		}
		while tooFarY {
			camera = camera.n8[(camera.pt.y - cursor.pt.y) > 0.0 ? 7 : 3]
		}
	}
}

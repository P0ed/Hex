enum Direction { case left, right, down, up }
enum Target { case prev, next }
enum Action { case a, b, c, d }
enum Menu { case no, yes }

enum Input { case direction(Direction), target(Target), action(Action), menu(Menu) }

extension State {

	mutating func apply(_ input: Input) {
		switch input {
		case let .direction(direction): moveCursor(direction)
		case .menu(.yes): endTurn()
		case .action(.a): primaryAction()
		case .action(.b): secondaryAction()
		case .target(.prev): prevUnit()
		case .target(.next): nextUnit()
		default: break
		}
	}
}

private extension State {

	mutating func moveCursor(_ direction: Direction) {
		let c = switch direction {
		case .left: cursor.neighbor(cursor.q % 2 == 0 ? .southWest : .northWest)
		case .right: cursor.neighbor(cursor.q % 2 == 0 ? .southEast : .northEast)
		case .down: cursor.neighbor(.south)
		case .up: cursor.neighbor(.north)
		}

		if c.distance(to: .zero) <= map.radius { cursor = c }
	}

	mutating func primaryAction() {
		let cursor = cursor

		if let selectedID = selectedUnit, let unit = self[selectedID] {
			if let dst = self[cursor] {
				if dst.player.team != unit.player.team {
					attack(src: unit, dst: dst)
				} else {
					selectUnit(dst)
				}
			} else {
				move(unit: unit, to: cursor)
			}
		} else {
			if let u = self[cursor], u.player == currentPlayer {
				selectUnit(u)
			}
		}
	}

	mutating func secondaryAction() {
		selectUnit(.none)
	}

	mutating func prevUnit() {
		nextUnit(reversed: true)
	}

	mutating func nextUnit(reversed: Bool = false) {
		let player = currentPlayer

		let units: AnyRandomAccessCollection<Unit> = reversed
		? .init(units.reversed())
		: .init(units)

		let idx = selectedUnit.flatMap { uid in
			units.enumerated().first { i, u in u.id == uid }?.offset
		}

		let validUnit: (Unit) -> Bool = { u in
			u.player == player && u.hasActions
		}

		let nextUnit = idx.flatMap { idx in
			units.dropFirst(idx + 1).first(where: validUnit)
		} ?? units.first(where: validUnit)

		if let nextUnit { selectUnit(nextUnit) }
	}
}

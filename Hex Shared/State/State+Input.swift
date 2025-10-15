enum Direction { case left, right, down, up }
enum Target { case prev, next }
enum Action { case a, b, c, d }

enum Input { case direction(Direction), target(Target), action(Action), menu }

extension State {

	mutating func apply(_ input: Input) {
		switch input {
		case let .direction(direction): moveCursor(direction)
		case .menu: endTurn()
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
		let c = cursor.neighbor(direction)

		if c.distance(to: .zero) <= map.radius {
			cursor = c
			while abs(camera.pt.x - cursor.pt.x) > 12 {
				camera = camera.neighbor((camera.pt.x - cursor.pt.x) > 0 ? .left : .right)
			}
			while abs(camera.pt.y - cursor.pt.y) > 8 {
				camera = camera.neighbor((camera.pt.y - cursor.pt.y) > 0 ? .down : .up)
			}
		}
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

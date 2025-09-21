enum Direction { case left, right, down, up }
enum Target { case prev, next }
enum Action { case a, b, c, d }
enum Menu { case no, yes }

enum Input { case direction(Direction), target(Target), action(Action), menu(Menu) }

extension State {

	mutating func moveCursor(_ direction: Direction) {
		let c = switch direction {
		case .left: cursor.neighbor(cursor.q % 2 == 0 ? 3 : 4)
		case .right: cursor.neighbor(cursor.q % 2 == 0 ? 1 : 0)
		case .down: cursor.neighbor(2)
		case .up: cursor.neighbor(5)
		}

		if c.distance(to: .zero) <= map.radii { cursor = c }
	}

	mutating func endTurn() {
		guard let idx = players.firstIndex(where: { $0.id == currentPlayer }) else { return }

		let nextIdx = (idx + 1) % players.count
		currentPlayer = players[nextIdx].id
		turn = nextIdx == 0 ? turn + 1 : turn
	}

	mutating func apply(_ input: Input) {
		switch input {
		case let .direction(direction): moveCursor(direction)
		case .menu(.yes): endTurn()
		case .action(.a): primaryAction()
		case .action(.b): secondaryAction()
		default: break
		}
	}

	mutating func primaryAction() {
		if let selectedUnit {
			if let u = self[cursor] {
				events.append(.attack(selectedUnit, u.id))
			} else {
				events.append(.move(selectedUnit, cursor))
			}
		} else {
			if let u = self[cursor] {
				selectedUnit = u.id
			}
		}
	}

	mutating func secondaryAction() {
		selectedUnit = nil
	}
}

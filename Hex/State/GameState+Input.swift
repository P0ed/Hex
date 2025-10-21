enum Direction { case left, right, down, up }
enum Target { case prev, next }
enum Action { case a, b, c, d }

enum Input {
	case direction(Direction)
	case target(Target)
	case action(Action)
	case menu
	case hex(Hex)
	case index(Int)
	case scale(Double)
}

@MainActor
extension GameState {

	var isHuman: Bool { self[player]?.ai == false }
	var canHandleInput: Bool { isHuman && events.isEmpty }

	mutating func apply(_ input: Input) {
		guard canHandleInput else { return }

		switch input {
		case .direction(let direction): moveCursor(direction)
		case .menu: endTurn()
		case .action(.a): primaryAction()
		case .action(.b): secondaryAction()
		case .action(.c): events.append(.menu)
		case .action(.d): break
		case .target(.prev): prevUnit()
		case .target(.next): nextUnit()
		case .hex(let hex): select(hex)
		case .index: break
		case .scale(let value): scale = value
		}
	}
}

@MainActor
private extension GameState {

	mutating func select(_ hex: Hex) {
		guard canHandleInput, map.contains(hex) else { return }

		cursor = hex
		primaryAction()
	}

	mutating func moveCursor(_ direction: Direction) {
		let hex = cursor.neighbor(direction)
		if map.contains(hex) { cursor = hex }
	}

	mutating func primaryAction() {
		if let selectedID = selectedUnit, let unit = self[selectedID] {
			if let dst = units[cursor] {
				if dst.player.team != unit.player.team {
					attack(src: unit.id, dst: dst.id)
				} else {
					selectUnit(dst == unit ? .none : dst.id)
				}
			} else if unit.canMove {
				move(unit: unit.id, to: cursor)
			} else if map.cities[cursor]?.controller == player {
				events.append(.shop)
			}
		} else {
			if let u = units[cursor], u.player == player {
				selectUnit(u.id)
			} else if map.cities[cursor]?.controller == player {
				events.append(.shop)
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
		let player = player

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

		if let nextUnit { selectUnit(nextUnit.id) }
	}
}

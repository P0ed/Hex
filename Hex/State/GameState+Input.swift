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

	var canHandleInput: Bool { !player.ai && events.isEmpty }

	mutating func apply(_ input: Input) {
		switch input {
		case .direction(let direction): moveCursor(direction)
		case .menu: events.append(.menu)
		case .action(.a): primaryAction()
		case .action(.b): secondaryAction()
		case .action(.c): break
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
		if let selectedID = selectedUnit {
			let unit = units[selectedID]

			if let (dstID, dst) = units[cursor] {
				if dst.country.team != unit.country.team {
					attack(src: selectedID, dst: dstID)
				} else if dstID == selectedID, unit.stats.unitType == .engineer, unit.untouched {
					events.append(.build)
				} else {
					selectUnit(dst == unit ? .none : dstID)
				}
			} else if unit.canMove {
				move(unit: selectedID, to: cursor)
			} else if buildings[cursor]?.country == country {
				events.append(.shop)
			} else {
				selectUnit(.none)
			}
		} else {
			if let (i, u) = units[cursor], u.country == country {
				selectUnit(i)
			} else if buildings[cursor]?.country == country {
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
		var idx = selectedUnit ?? (reversed ? units.count - 1 : 0)
		let country = country

		for _ in units.indices {
			let u = units[idx % units.count]
			if u.alive, u.country == country, u.hasActions {
				return selectUnit(idx)
			}
			idx += reversed ? -1 : 1
		}
		selectUnit(nil)
	}
}

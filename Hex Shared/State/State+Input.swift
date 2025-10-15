enum Direction { case left, right, down, up }
enum Target { case prev, next }
enum Action { case a, b, c, d }

enum Input { case direction(Direction), target(Target), action(Action), menu, tap(Hex) }

extension State {

	var isHuman: Bool { self[currentPlayer]?.ai == false }
	var canHandleInput: Bool { /*isHuman && */events.isEmpty }

	mutating func apply(_ input: Input) {
		guard canHandleInput else { return }

		switch input {
		case .direction(let direction): moveCursor(direction)
		case .menu: endTurn()
		case .action(.a): primaryAction()
		case .action(.b): secondaryAction()
		case .action(.c): break
		case .action(.d): break
		case .target(.prev): prevUnit()
		case .target(.next): nextUnit()
		case .tap(let hex): tap(hex)
		}
	}
}

private extension State {

	mutating func tap(_ hex: Hex) {
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
			if let dst = self.units[cursor] {
				if dst.player.team != unit.player.team {
					attack(src: unit, dst: dst)
				} else {
					selectUnit(dst)
				}
			} else {
				move(unit: unit, to: cursor)
			}
		} else {
			if let u = self.units[cursor], u.player == currentPlayer {
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

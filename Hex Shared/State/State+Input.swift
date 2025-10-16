enum Direction { case left, right, down, up }
enum Target { case prev, next }
enum Action { case a, b, c, d }

enum Input { case direction(Direction), target(Target), action(Action), menu, tap(Hex) }

@MainActor
extension GameState {

	var isHuman: Bool { self[currentPlayer]?.ai == false }
	var canHandleInput: Bool { /*isHuman && */events.isEmpty }

	mutating func apply(_ input: Input) {
		guard canHandleInput else { return }

		if case .some = shop {
			shopInput(input)
		} else {
			rootInput(input)
		}
	}
}

@MainActor
private extension GameState {

	mutating func rootInput(_ input: Input) {
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

	mutating func shopInput(_ input: Input) {
		guard var shop else { return }

		switch input {
		case .direction(let direction):
			shop.moveCursor(direction)
			self.shop = shop
		case .action(.a):
			let unit = shop.buyUnit()
			units.append(unit)
			events.append(.spawn(unit.id))
			self.shop = .none
		case .action(.b):
			self.shop = .none
		default: break
		}
	}

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
			if let dst = units[cursor] {
				if dst.player.team != unit.player.team {
					attack(src: unit, dst: dst)
				} else {
					selectUnit(dst)
				}
			} else {
				move(unit: unit, to: cursor)
			}
		} else {
			if let u = units[cursor], u.player == currentPlayer {
				selectUnit(u)
			} else if let c = map.cities[cursor], c.controller == currentPlayer {
				displayShop(at: cursor)
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

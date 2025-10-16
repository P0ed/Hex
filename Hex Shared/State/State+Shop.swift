@MainActor
extension GameState {

	mutating func displayShop(at hex: Hex) {
		guard let city = map.cities[hex],
			  city.controller == currentPlayer,
			  self.units[hex] == nil
		else { return }

		shop = Shop(
			units: shopUnitsForCurrentPlayer,
			cursor: 0,
			location: hex
		)
	}

	mutating func closeShop() {
		shop = .none
	}

	var shopUnitsForCurrentPlayer: [Unit] {
		[
			.infantry(id: 0, player: currentPlayer, position: .zero),
			.tank(id: 0, player: currentPlayer, position: .zero)
		]
	}
}

@MainActor
extension Shop {

	mutating func moveCursor(_ direction: Direction) {
		switch direction {
		case .up: cursor = (cursor + 1) % units.count
		case .down: cursor = (cursor - 1 + units.count) % units.count
		default: break
		}
	}

	mutating func buyUnit() -> Unit {
		var unit = units[cursor]
		unit.id = .next()
		unit.position = location
		unit.stats.fired = true
		unit.stats.mp = 0

		return unit
	}
}

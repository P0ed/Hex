@MainActor
extension GameState {

	var unitTemplates: [Unit] {
		[
			.infantry(id: 0, player: currentPlayer, position: .zero),
			.tank(id: 0, player: currentPlayer, position: .zero)
		]
	}

	mutating func buy(_ template: Unit, at position: Hex) {
		let unit = template.buy(at: position)
		units.append(unit)
		events.append(.spawn(unit.id))
	}
}

@MainActor
extension Unit {

	func buy(at position: Hex) -> Unit {
		modifying(self) { u in
			u.id = .next()
			u.position = position
			u.stats.fired = true
			u.stats.mp = 0
		}
	}
}

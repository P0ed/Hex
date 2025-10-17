@MainActor
extension GameState {

	var unitTemplates: [Unit] {
		[
			Unit(id: .next, player: currentPlayer, position: .zero, stats: .shop >< .inf39),
			Unit(id: .next, player: currentPlayer, position: .zero, stats: .shop >< .tank39),
			Unit(id: .next, player: currentPlayer, position: .zero, stats: .shop >< .art39),
		]
	}

	mutating func buy(_ template: Unit, at position: Hex) {
		guard prestige >= template.cost else { return }
		let unit = template.buy(at: position)
		prestige -= template.cost
		units.append(unit)
		events.append(.spawn(unit.id))
	}
}

@MainActor
extension Unit {

	func buy(at position: Hex) -> Unit {
		modifying(self) { u in
			u.id = .make()
			u.position = position
		}
	}
}

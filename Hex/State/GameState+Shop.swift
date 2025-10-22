@MainActor
extension GameState {

	var unitTemplates: [Unit] {
		[
			Unit(id: .next, player: player, position: .zero, stats: .shop >< .inf),
			Unit(id: .next, player: player, position: .zero, stats: .shop >< .recon),
			Unit(id: .next, player: player, position: .zero, stats: .shop >< .tank),
			Unit(id: .next, player: player, position: .zero, stats: .shop >< .art),
			Unit(id: .next, player: player, position: .zero, stats: .shop >< .builder),
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

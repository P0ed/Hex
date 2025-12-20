extension TacticalState {

	var unitTemplates: [Unit] {
		[
			Unit(country: country, position: .zero, stats: .shop >< .inf),
			Unit(country: country, position: .zero, stats: .shop >< .recon),
			Unit(country: country, position: .zero, stats: .shop >< .t72),
			Unit(country: country, position: .zero, stats: .shop >< .art),
			Unit(country: country, position: .zero, stats: .shop >< .builder),
			Unit(country: country, position: .zero, stats: .shop >< .truck),
		]
	}

	mutating func buy(_ template: Unit, at position: XY) {
		guard player.prestige >= template.cost, units[position] == nil else { return }

		let unit = modifying(template) { u in
			u.position = position
		}
		player.prestige.decrement(by: unit.cost)
		events.add(.spawn(units.add(unit)))
	}
}

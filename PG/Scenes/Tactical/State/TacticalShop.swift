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

	var buildingTemplates: [Building] {
		[
//			Building(country: country, position: .zero, type: .barracks),
//			Building(country: country, position: .zero, type: .factory),
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

	mutating func build(_ template: Building, by engineer: UID) {
		guard units[engineer].alive, units[engineer].stats.unitType == .engineer,
			  units[engineer].untouched, buildings[units[engineer].position] == nil
		else { return }

		let building = modifying(template) { b in
			b.position = units[engineer].position
		}
		buildings.add(building)
		units[engineer].stats.mp = 0
		units[engineer].stats.ap = 0
		selectUnit(.none)
	}
}

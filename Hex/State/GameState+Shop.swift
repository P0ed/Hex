@MainActor
extension GameState {

	var unitTemplates: [Unit] {
		[
			Unit(id: .next, country: country, position: .zero, stats: .shop >< .inf),
			Unit(id: .next, country: country, position: .zero, stats: .shop >< .recon),
			Unit(id: .next, country: country, position: .zero, stats: .shop >< .tank),
			Unit(id: .next, country: country, position: .zero, stats: .shop >< .art),
			Unit(id: .next, country: country, position: .zero, stats: .shop >< .builder),
			Unit(id: .next, country: country, position: .zero, stats: .shop >< .truck),
		]
	}

	var buildingTemplates: [Building] {
		[
			Building(country: country, position: .zero, type: .barracks),
			Building(country: country, position: .zero, type: .factory),
		]
	}

	mutating func buy(_ template: Unit, at position: Hex) {
		guard prestige >= template.cost, units[position] == nil else { return }

		let unit = modifying(template) { u in
			u.id = .make()
			u.position = position
		}
		prestige -= unit.cost
		units.append(unit)
		events.append(.spawn(unit.id))
	}

	mutating func build(_ template: Building, by engineer: Ref<Unit>) {
		guard units[engineer].stats.unitType == .engineer,
			  units[engineer].untouched,
			  buildings[units[engineer].position] == nil
		else { return }

		let building = modifying(template) { b in b.position = units[engineer].position }
		buildings.append(building)
		events.append(.reflag)
		units[engineer].stats.mp = 0
		units[engineer].stats.ap = 0
		selectUnit(.none)
	}
}

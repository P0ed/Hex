struct State: ~Copyable {
	var hq: HQState?
	var strategic: StrategicState?
	var tactical: TacticalState?
}

private let defaultUnits: [Unit] = [
	Unit(country: .ukr, position: XY(0, 0), stats: .base >< .truck),
	Unit(country: .ukr, position: XY(0, 1), stats: .base >< .inf >< .veteran),
	Unit(country: .ukr, position: XY(0, 2), stats: .base >< .strv122 >< .elite),
	Unit(country: .ukr, position: XY(0, 3), stats: .base >< .strv122 >< .elite),
	Unit(country: .ukr, position: XY(1, 0), stats: .base >< .recon >< .elite),
	Unit(country: .ukr, position: XY(1, 1), stats: .base >< .art >< .veteran),
]

final class Core {
	private(set) var state = State()

	func new() {
		let units = Speicher<32, Unit>(head: defaultUnits, tail: .dead)
		let events = Speicher<32, HQEvent>(
			head: units.map { i, u in .spawn(i) },
			tail: .none
		)

		state = State(
			hq: HQState(
				player: Player(country: .ukr),
				units: units,
				events: events
			)
		)
	}

	func load() {}

	func save() {}

	func store(hq: borrowing HQState) {
		state.hq = clone(hq)
		save()
	}

	func store(tactical: borrowing TacticalState) {
		guard state.hq != nil else { return }
		state.tactical = clone(tactical)
		save()
	}

	func complete(tactical: borrowing TacticalState) {
		guard let player = state.hq?.player else { return }

		let units = tactical.units.compactMap { _, u in
			u.country == player.country ? u : nil
		}
		state.hq?.units = .init(head: units, tail: .dead)

		state.tactical = nil
		save()
	}
}

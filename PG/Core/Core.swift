struct State: ~Copyable {
	var hq: HQState?
	var strategic: StrategicState?
	var tactical: TacticalState?
}

final class Core {
	private(set) var state = State()

	func new() {
		state = State(
			hq: HQState(
				player: Player(country: .ukr),
				units: .init(head: [], tail: .dead),
				event: .none
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

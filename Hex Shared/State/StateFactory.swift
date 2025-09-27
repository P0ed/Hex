@MainActor
extension State {

	static var initial: State {
		.init(
			map: Map(),
			players: [
				.init(id: .axis(0), money: 100),
				.init(id: .allies(0), money: 100)
			],
			units: [
				.tank(player: .axis(0), position: Hex(0, -1)),
				.tank(player: .axis(0), position: Hex(-4, 1)),
				.infantry(player: .axis(0), position: Hex(-4, 0)),
				.infantry(player: .axis(0), position: Hex(1, -2)),

				.infantry(player: .allies(0), position: Hex(0, 3)),
				.infantry(player: .allies(0), position: Hex(3, 1)),
			]
		)
	}
}

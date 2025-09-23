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
				.tank(player: .axis(0), position: .zero.neighbor(.southWest).neighbor(.south)),
				.infantry(player: .axis(0), position: .zero.neighbor(.south).neighbor(.south)),
				.infantry(player: .axis(0), position: .zero.neighbor(.southEast).neighbor(.southEast)),

				.infantry(player: .allies(0), position: .zero.neighbor(.north).neighbor(.north)),
				.infantry(player: .allies(0), position: .zero.neighbor(.northEast).neighbor(.northEast)),
			]
		)
	}
}

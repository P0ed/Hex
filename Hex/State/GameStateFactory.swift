@MainActor
extension GameState {

	static func random(size: Int = 8, seed: Int = 0) -> GameState {
		GameState(
			map: Map(width: size * 4, height: size * 2, seed: seed),
			players: [
				Player(country: .ukr),
				Player(country: .usa, ai: true),
				Player(country: .rus, ai: true),
			],
			buildings: [
				Building(country: .ukr, position: Hex(-5, -2), type: .city),
				Building(country: .usa, position: Hex(2, 4), type: .city),
				Building(country: .usa, position: Hex(-2, 6), type: .city),
				Building(country: .rus, position: Hex(10, 1), type: .city),
				Building(country: .rus, position: Hex(11, -2), type: .city),
			],
			units: [
				Unit(country: .ukr, position: Hex(0, -3), stats: .base >< .builder),
				Unit(country: .ukr, position: Hex(0, -4), stats: .base >< .truck),
				Unit(country: .ukr, position: Hex(-4, 0), stats: .base >< .inf >< .veteran),
				Unit(country: .ukr, position: Hex(0, -1), stats: .base >< .strv122 >< .elite),
				Unit(country: .ukr, position: Hex(0, -2), stats: .base >< .strv122 >< .elite),
				Unit(country: .ukr, position: Hex(-4, 1), stats: .base >< .recon >< .elite),
				Unit(country: .ukr, position: Hex(-1, -1), stats: .base >< .art >< .veteran),

				Unit(country: .usa, position: Hex(0, 3), stats: .base >< .inf),
				Unit(country: .usa, position: Hex(3, 1), stats: .base >< .inf),
				Unit(country: .usa, position: Hex(4, 2), stats: .base >< .m1A2),
				Unit(country: .usa, position: Hex(-2, 5), stats: .base >< .art),
				Unit(country: .usa, position: Hex(2, 3), stats: .base >< .art),

				Unit(country: .rus, position: Hex(10, 0), stats: .base >< .t72),
				Unit(country: .rus, position: Hex(10, -1), stats: .base >< .t72),
				Unit(country: .rus, position: Hex(11, -1), stats: .base >< .t72),
				Unit(country: .rus, position: Hex(11, -3), stats: .base >< .t72),
			]
		)
	}
}

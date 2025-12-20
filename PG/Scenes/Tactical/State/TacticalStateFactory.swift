extension TacticalState {

	static func random(size: Int = .random(in: 12...32), seed: Int = .random(in: 0...1023)) -> TacticalState {
		TacticalState(
			map: Map(size: size, seed: seed),
			players: [
				Player(country: .ukr),
				Player(country: .usa, ai: true),
				Player(country: .rus, ai: true),
			],
			buildings: [
				Building(country: .ukr, position: XY(1, 1), type: .city),
				Building(country: .usa, position: XY(5, 10), type: .city),
				Building(country: .usa, position: XY(8, 8), type: .city),
				Building(country: .rus, position: XY(13, 1), type: .city),
				Building(country: .rus, position: XY(11, 5), type: .city),
			],
			units: [
				Unit(country: .ukr, position: XY(0, 0), stats: .base >< .truck),
				Unit(country: .ukr, position: XY(4, 0), stats: .base >< .inf >< .veteran),
				Unit(country: .ukr, position: XY(0, 1), stats: .base >< .strv122 >< .elite),
				Unit(country: .ukr, position: XY(0, 2), stats: .base >< .strv122 >< .elite),
				Unit(country: .ukr, position: XY(1, 0), stats: .base >< .recon >< .elite),
				Unit(country: .ukr, position: XY(1, 1), stats: .base >< .art >< .veteran),

				Unit(country: .usa, position: XY(5, 7), stats: .base >< .inf),
				Unit(country: .usa, position: XY(4, 6), stats: .base >< .inf),
				Unit(country: .usa, position: XY(4, 5), stats: .base >< .m1A2),
				Unit(country: .usa, position: XY(5, 5), stats: .base >< .art),
				Unit(country: .usa, position: XY(5, 4), stats: .base >< .art),

				Unit(country: .rus, position: XY(10, 0), stats: .base >< .t72),
				Unit(country: .rus, position: XY(10, 1), stats: .base >< .t72),
				Unit(country: .rus, position: XY(11, 1), stats: .base >< .t72),
				Unit(country: .rus, position: XY(11, 3), stats: .base >< .t72),
			]
		)
	}
}

import GameplayKit

@MainActor
extension GameState {

	static func random(radius: Int = 64, seed: Int = 0) -> GameState {

		GameState(
			map: Map(radius: radius, seed: seed),
			players: [
				Player(country: .ukr),
				Player(country: .usa, ai: true),
				Player(country: .rus, ai: true),
			],
			buildings: [
				Building(country: .ukr, position: Hex(-1, -3), type: .city),
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

@MainActor
extension Map {

	init(radius: Int, seed: Int) {
		self = Map(radius: radius)

		let height = GKNoiseMap.height(radius: radius, seed: seed)
		let humidity = GKNoiseMap.humidity(radius: radius, seed: seed + 1)

		let pairs = [Hex].circle(radius).map { hex in
			let (x, y) = converting(hex)
			let pos = SIMD2<Int32>(Int32(x), Int32(y))
			return (hex, Terrain.terrain(
				at: height.value(at: pos),
				humidity: humidity.value(at: pos)
			))
		}
		terrain = Dictionary(pairs, uniquingKeysWith: { _, r in r })
	}
}

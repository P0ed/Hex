import GameplayKit

@MainActor
extension GameState {

	static func random(radius: Int = 12, seed: Int = 0) -> GameState {
		.init(
			map: Map(radius: radius, seed: seed),
			players: [
				Player(id: .deu),
				Player(id: .usa, ai: true),
			],
			units: [
				Unit(id: .make(), player: .deu, position: Hex(-4, 0), stats: .base >< .inf39),
				Unit(id: .make(), player: .deu, position: Hex(1, -2), stats: .base >< .inf39),
				Unit(id: .make(), player: .deu, position: Hex(0, -1), stats: .base >< .tank39),
				Unit(id: .make(), player: .deu, position: Hex(-4, 1), stats: .base >< .tank39),
				Unit(id: .make(), player: .deu, position: Hex(-1, 1), stats: .base >< .art39),

				Unit(id: .make(), player: .usa, position: Hex(0, 3), stats: .base >< .inf39),
				Unit(id: .make(), player: .usa, position: Hex(3, 1), stats: .base >< .inf39),
				Unit(id: .make(), player: .usa, position: Hex(4, 2), stats: .base >< .tank39),
				Unit(id: .make(), player: .usa, position: Hex(-2, 5), stats: .base >< .art39),
			]
		)
	}
}

@MainActor
extension Map {

	init(radius: Int, seed: Int) {
		self = Map(radius: radius)

		let noise = GKNoiseMap.terrain(radius: radius, seed: seed)
		let pairs = [Hex].circle(radius).map { hex in
			let (x, y) = converting(hex)
			let pos = SIMD2<Int32>(Int32(x), Int32(y))
			return (hex, Terrain.terrain(at: noise.value(at: pos)))
		}
		terrain = Dictionary(pairs, uniquingKeysWith: { _, r in r })

		terrain[Hex(1, -3)] = .city
		terrain[Hex(2, 3)] = .city
		terrain[Hex(-2, 5)] = .city

		cities = [
			Hex(1, -3): City(name: "Berlin", controller: .deu),
			Hex(2, 3): City(name: "Washington", controller: .usa),
			Hex(-2, 5): City(name: "London", controller: .usa),
		]
	}
}

import GameplayKit

@MainActor
extension State {

	static func random(radius: Int = 24, seed: Int = 0) -> State {
		.init(
			map: Map(radius: radius, seed: seed),
			players: [
				Player(id: .axis),
				Player(id: .allies, ai: true),
			],
			units: [
				.infantry(player: .axis, position: Hex(-4, 0)),
				.infantry(player: .axis, position: Hex(1, -2)),
				.tank(player: .axis, position: Hex(0, -1)),
				.tank(player: .axis, position: Hex(-4, 1)),
				.art(player: .axis, position: Hex(-3, 2)),

				.infantry(player: .allies, position: Hex(0, 3)),
				.infantry(player: .allies, position: Hex(3, 1)),
				.tank(player: .allies, position: Hex(4, 2)),
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

		terrain[Hex(2, 3)] = .city
		terrain[Hex(1, -3)] = .city

		cities = [
			Hex(1, -3): City(name: "Berlin", controller: .axis),
			Hex(2, 3): City(name: "Washington", controller: .allies),
		]
	}
}

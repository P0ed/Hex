import GameplayKit

@MainActor
extension GameState {

	static func random(radius: Int = 12, seed: Int = 0) -> GameState {
		.init(
			map: Map(radius: radius, seed: seed),
			players: [
				Player(id: .deu),
				Player(id: .usa, ai: false),
			],
			buildings: [
				Building(player: .deu, position: Hex(-1, -3), type: .city),
				Building(player: .usa, position: Hex(2, 4), type: .city),
				Building(player: .usa, position: Hex(-2, 6), type: .city),
			],
			units: [
				Unit(id: .make(), player: .deu, position: Hex(0, -3), stats: .base >< .builder),
				Unit(id: .make(), player: .deu, position: Hex(-4, 0), stats: .base >< .inf),
				Unit(id: .make(), player: .deu, position: Hex(0, -1), stats: .base >< .tank),
				Unit(id: .make(), player: .deu, position: Hex(-4, 1), stats: .base >< .recon),
				Unit(id: .make(), player: .deu, position: Hex(-1, -1), stats: .base >< .art),

				Unit(id: .make(), player: .usa, position: Hex(0, 3), stats: .base >< .inf),
				Unit(id: .make(), player: .usa, position: Hex(3, 1), stats: .base >< .inf),
				Unit(id: .make(), player: .usa, position: Hex(4, 2), stats: .base >< .tank),
				Unit(id: .make(), player: .usa, position: Hex(-2, 5), stats: .base >< .art),
				Unit(id: .make(), player: .usa, position: Hex(2, 3), stats: .base >< .art),
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

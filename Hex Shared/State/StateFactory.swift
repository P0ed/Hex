import GameplayKit

@MainActor
extension State {

	static func random(radii: Int = 16, seed: Int = 0) -> State {
		.init(
			map: Map(radii: radii, seed: seed),
			players: [
				Player(id: .axis),
				Player(id: .allies)
			],
			units: [
				.infantry(player: .axis, position: Hex(-4, 0)),
				.infantry(player: .axis, position: Hex(1, -2)),
				.tank(player: .axis, position: Hex(0, -1)),
				.tank(player: .axis, position: Hex(-4, 1)),

				.infantry(player: .allies, position: Hex(0, 3)),
				.infantry(player: .allies, position: Hex(3, 1)),
				.tank(player: .allies, position: Hex(4, 2)),
			]
		)
	}
}

@MainActor
extension Map {

	init(radii: Int, seed: Int) {
		self = Map(radii: radii)

		let noise = GKNoiseMap.terrain(radii: radii, seed: seed)
		let pairs = [Hex].circle(radii).map { hex in
			let (x, y) = converting(hex)
			let pos = SIMD2<Int32>(Int32(x), Int32(y))
			return (hex, Terrain.terrain(at: noise.value(at: pos)))
		}
		terrain = Dictionary(pairs, uniquingKeysWith: { _, r in r })
	}
}

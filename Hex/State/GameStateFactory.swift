import GameplayKit

@MainActor
extension GameState {

	static func random(radius: Int = 12, seed: Int = 0) -> GameState {

		func mkUnit(_ player: Country, _ position: Hex, _ stats: Stats) -> Unit {
			Unit(id: .make(), country: player, position: position, stats: .base >< stats)
		}

		return GameState(
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
				mkUnit(.ukr, Hex(0, -3), .builder),
				mkUnit(.ukr, Hex(0, -4), .truck),
				mkUnit(.ukr, Hex(-4, 0), .inf >< .veteran),
				mkUnit(.ukr, Hex(0, -1), .tank >< .veteran),
				mkUnit(.ukr, Hex(-4, 1), .recon >< .elite),
				mkUnit(.ukr, Hex(-1, -1), .art >< .veteran),

				mkUnit(.usa, Hex(0, 3), .inf),
				mkUnit(.usa, Hex(3, 1), .inf),
				mkUnit(.usa, Hex(4, 2), .tank),
				mkUnit(.usa, Hex(-2, 5), .art),
				mkUnit(.usa, Hex(2, 3), .art),

				mkUnit(.rus, Hex(10, 0), .tank),
				mkUnit(.rus, Hex(10, -1), .tank),
				mkUnit(.rus, Hex(11, -1), .tank),
				mkUnit(.rus, Hex(11, -3), .tank),
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

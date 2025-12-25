extension TacticalState {

	static func random(
		player: Player = Player(country: .ukr),
		units: [Unit]? = nil,
		size: Int = .random(in: 16...32),
		seed: Int = .random(in: 0...1023)
	) -> TacticalState {
		TacticalState(
			map: Map(size: size, seed: seed),
			players: [
				player,
				Player(country: .usa, ai: true),
				Player(country: .rus, ai: true),
			],
			buildings: [
				Building(country: player.country, position: XY(1, 1), type: .city),
				Building(country: .usa, position: XY(5, 10), type: .city),
				Building(country: .usa, position: XY(8, 8), type: .city),
				Building(country: .rus, position: XY(13, 1), type: .city),
				Building(country: .rus, position: XY(11, 5), type: .city),
			],
			units: (units ?? .base(player.country)) + .enemy(player.country)
		)
	}
}

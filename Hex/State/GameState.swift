struct GameState: ~Copyable {
	var map: Map<Terrain>

	var players: [Player]
	var buildings: [Building]
	var units: Speicher<1024, Unit>
	var d20: D20 = .init(seed: 0)

	var turn: UInt32 = 0

	var cursor: XY = .zero
	var camera: XY = .zero
	var selectedUnit: UID?
	var selectable: Set<XY>?
	var scale: Double = 1.0

	var events: [Event] = []
}

extension GameState {

	init(map: consuming Map<Terrain>, players: [Player], buildings: [Building], units: [Unit]) {
		self.map = map
		self.players = players
		self.buildings = buildings
		self.units = .init(head: units, tail: .dead)

		buildings.forEach { b in
			switch b.type {
			case .city: self.map[b.position] = .city
			}
		}

		self.players = players.mapInPlace { p in p.visible = vision(for: p.country) }
	}
}

struct Building: Hashable, Codable {
	var country: Country
	var position: XY
	var type: BuildingType
}

enum BuildingType: UInt8, Hashable, Codable {
	case city
}

enum Event: Hashable, Codable {
	case spawn(UID)
	case move(UID, Int)
	case attack(UID, UID, Unit)
	case reflag
	case nextDay
	case shop
	case build
	case menu
	case gameOver
}

struct D20: Hashable, Codable {
	var seed: UInt64
}

extension GameState {

	var playerIndex: Int { Int(turn) % players.count }

	var player: Player {
		get { players[playerIndex] }
		set { players[playerIndex] = newValue }
	}

	var country: Country { player.country }
}

extension Building {

	var cost: UInt16 {
		switch type {
		case .city: 1600
		}
	}

	var income: UInt16 {
		switch type {
		case .city: 40
		}
	}
}

extension D20: RandomNumberGenerator {

	// SplitMix64
	mutating func next() -> UInt64 {
		seed &+= 0x9e3779b97f4a7c15
		var z: UInt64 = seed
		z = (z ^ (z &>> 30)) &* 0xbf58476d1ce4e5b9
		z = (z ^ (z &>> 27)) &* 0x94d049bb133111eb
		return z ^ (z &>> 31)
	}

	mutating func callAsFunction() -> Int {
		.random(in: 0..<20, using: &self)
	}
}

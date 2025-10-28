struct GameState: Hashable, Codable {
	var map: Map

	var players: [Player]
	var buildings: [Building]
	var units: [Unit]
	var d20: D20 = .init(seed: 0)

	var turn: UInt32 = 0

	var cursor: Hex = .zero
	var camera: Hex = .zero
	var selectedUnit: UnitID?
	var selectable: Set<Hex>?
	var scale: Double = 1.0

	var events: [Event] = []
}

extension GameState {

	init(map: Map, players: [Player], buildings: [Building], units: [Unit]) {
		self.map = map
		self.players = players
		self.buildings = buildings
		self.units = units

		self.players = players.mapInPlace { p in p.visible = vision(for: p.country) }
	}
}

struct Building: Hashable, Codable {
	var country: Country
	var position: Hex
	var type: BuildingType
}

enum BuildingType: UInt8, Hashable, Codable {
	case city, barracks, factory, airfield, radar
}

struct Player: Hashable, Codable {
	var country: Country
	var ai: Bool = false
	var alive: Bool = true
	var prestige: UInt16 = 1000
	var visible: Set<Hex> = []
}

enum Country: UInt8, Hashable, Codable {
	case dnr, lnr, irn, isr, rus, swe, ukr, usa
}

enum Team: UInt8, Hashable, Codable {
	case axis, allies, soviet
}

extension Country {

	var team: Team {
		switch self {
		case .swe, .ukr: .axis
		case .isr, .usa: .allies
		case .dnr, .lnr, .irn, .rus: .soviet
		}
	}
}

enum Event: Hashable, Codable {
	case spawn(UnitID)
	case move(UnitID, Int)
	case attack(UnitID, Unit)
	case reflag
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

	var playerUnits: LazyFilterSequence<[Unit]> {
		units.lazy.filter { [country] u in u.country == country }
	}
	var enemyUnits: LazyFilterSequence<[Unit]> {
		units.lazy.filter { [team = country.team] u in u.country.team != team }
	}

	var playerBuildings: LazyFilterSequence<[Building]> {
		buildings.lazy.filter { [team = country.team] b in b.country.team == team }
	}
	var enemyBuildings: LazyFilterSequence<[Building]> {
		buildings.lazy.filter { [team = country.team] b in b.country.team != team }
	}
}

extension [Unit] {

	subscript(_ hex: Hex) -> Ref<Unit>? {
		firstIndex { u in u.position == hex }.map(Ref.init)
	}

	subscript(_ uid: UnitID) -> Ref<Unit> {
		Ref(index: firstIndex { u in u.id == uid }!)
	}
}

extension [Building] {

	subscript(_ hex: Hex) -> Building? {
		first { u in u.position == hex }
	}
}

extension Building {

	var cost: UInt16 {
		switch type {
		case .city: 1600
		case .barracks: 300
		case .factory: 500
		case .airfield: 700
		case .radar: 400
		}
	}

	var income: UInt16 {
		switch type {
		case .city: 40
		default: 0
		}
	}
}

extension D20: RandomNumberGenerator {

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

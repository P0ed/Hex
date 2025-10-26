struct GameState: Hashable, Codable {
	var map: Map

	var players: [Player]
	var buildings: [Building]
	var units: [Unit]
	var d20: D20 = .init(seed: 0)

	var player: PlayerID = .deu
	var turn: UInt32 = 0

	var cursor: Hex = .zero
	var camera: Hex = .zero
	var selectedUnit: UnitID?
	var selectable: Set<Hex>?
	var scale: Double = 1.0

	var events: [Event] = []
}

struct Building: Hashable, Codable {
	var player: PlayerID
	var position: Hex
	var type: BuildingType
}

enum BuildingType: UInt8, Hashable, Codable {
	case city, barracks, factory, airfield, radar
}

struct Player: Hashable, Codable {
	var id: PlayerID
	var ai: Bool = false
	var prestige: UInt16 = 0
	var visible: Set<Hex> = []
}

enum Team: UInt8, Hashable, Codable { case axis, allies, soviet, neutral }

enum Event: Hashable, Codable {
	case spawn(UnitID)
	case update(UnitID)
	case move(UnitID, Int)
	case attack(UnitID, UnitID, Bool)
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

	var visible: Set<Hex> { players[player].visible }

	var playerUnits: LazyFilterSequence<[Unit]> {
		units.lazy.filter { [player] u in u.player == player }
	}
	var enemyUnits: LazyFilterSequence<[Unit]> {
		units.lazy.filter { [team = player.team] u in u.player.team != team }
	}

	var playerBuildings: LazyFilterSequence<[Building]> {
		buildings.lazy.filter { [team = player.team] b in b.player.team == team }
	}
	var enemyBuildings: LazyFilterSequence<[Building]> {
		buildings.lazy.filter { [team = player.team] b in b.player.team != team }
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

extension [Player] {

	subscript(_ pid: PlayerID) -> Player {
		get {
			first { p in p.id == pid }!
		}
		set {
			self[firstIndex { p in p.id == pid }!] = newValue
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

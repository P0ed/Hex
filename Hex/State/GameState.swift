struct GameState: Hashable, Codable {
	var map: Map

	var players: [Player]
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

struct Player: Hashable, Codable {
	var id: PlayerID
	var ai: Bool = false
	var prestige: UInt16 = 0
	var science: UInt16 = 0
	var visible: Set<Hex> = []
}

enum Team: Hashable, Codable { case axis, allies }

enum Event: Hashable, Codable {
	case spawn(UnitID)
	case kill(UnitID)
	case move(UnitID)
	case attack(UnitID, UnitID)
	case reflag
	case shop
	case menu
	case gameOver
}

struct D20: Hashable, Codable {
	var seed: UInt64
}

extension GameState {

	var visible: Set<Hex> { self[player]?.visible ?? [] }

	subscript(_ pid: PlayerID) -> Player? {
		get {
			players.first(where: { p in p.id == pid })
		}
		set {
			if let idx = players.firstIndex(where: { p in p.id == pid }) {
				if let newValue {
					players[idx] = newValue
				} else {
					players.remove(at: idx)
				}
			}
		}
	}

	subscript(_ uid: UnitID) -> Unit? {
		get {
			units.first(where: { u in u.id == uid })
		}
		set {
			if let idx = units.firstIndex(where: { u in u.id == uid }) {
				if let newValue {
					units[idx] = newValue
				} else {
					units.fastRemove(at: idx)
				}
			}
		}
	}

	var playerUnits: LazyFilterSequence<[Unit]> {
		units.lazy.filter { [player] u in u.player == player }
	}

	var enemyUnits: LazyFilterSequence<[Unit]> {
		units.lazy.filter { [team = player.team] u in u.player.team != team }
	}
}

extension [Unit] {
	subscript(_ hex: Hex) -> Unit? { first { u in u.position == hex } }
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

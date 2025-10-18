struct GameState: Hashable, Codable {
	var map: Map

	var players: [Player]
	var units: [Unit]

	var currentPlayer: PlayerID = .axis
	var turn: UInt32 = 0
	var visible: Set<Hex> = []

	var cursor: Hex = .zero
	var camera: Hex = .zero
	var selectedUnit: UnitID?
	var selectable: Set<Hex>?

	var events: [Event] = []
}

struct Player: Hashable, Codable {
	var id: PlayerID
	var ai: Bool = false
	var prestige: UInt16 = 0
	var science: UInt16 = 0
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

extension GameState {

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
					units.remove(at: idx)
				}
			}
		}
	}
}

extension [Unit] {
	subscript(_ hex: Hex) -> Unit? { first { u in u.position == hex } }
}

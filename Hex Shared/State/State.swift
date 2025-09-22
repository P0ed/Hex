struct State: Hashable, Codable {
	var map: Map

	var players: [Player]
	var units: [Unit]

	var cursor: Hex = .zero
	var currentPlayer: PlayerID = .axis(0)
	var turn: UInt32 = 0
	var selectedUnit: UnitID?

	var events: [Event] = []
}

struct Player: Hashable, Codable {
	var id: PlayerID
	var money: UInt32
}

enum Team: UInt8, Hashable, Codable { case axis, allies }

enum Event: Hashable, Codable {
	case spawn(UnitID)
	case kill(UnitID)
	case move(UnitID)
	case attack(UnitID, UnitID)
}

extension State {

	subscript(_ pid: PlayerID) -> Player? {
		get {
			players.first(where: { $0.id == pid })
		}
		set {
			if let idx = players.firstIndex(where: { $0.id == pid }) {
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
			units.first(where: { $0.id == uid })
		}
		set {
			if let idx = units.firstIndex(where: { $0.id == uid }) {
				if let newValue {
					units[idx] = newValue
				} else {
					units.remove(at: idx)
				}
			}
		}
	}

	subscript(_ hex: Hex) -> Unit? {
		units.first(where: { $0.position == hex })
	}
}

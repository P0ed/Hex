import HexKit

struct State: Hashable, Codable {
	var cursor: Hex = .zero
	var bounds: Int = 8

	var players: [Player]
	var currentPlayer: PlayerID = 0
	var turn: Int = 0

	var selectedUnit: UnitID?
	var units: [Unit]

	var events: [Event] = []
}

typealias UnitID = Int16
typealias PlayerID = Int16

struct Player: Hashable, Codable {
	var id: PlayerID
	var team: Team
	var money: Int
}

enum Team: Hashable, Codable { case left, right }

enum Event: Hashable, Codable {
	case move(Int, Hex)
}

struct Unit: Hashable, Codable {
	var id: UnitID
	var player: PlayerID
	var position: Hex
	var hp: HP
	var atk: Int
	var def: Int
	var mov: Int
}

struct HP: Hashable, Codable {
	var value: Int
	var max: Int

	init(_ hp: Int) {
		value = hp
		max = hp
	}
}

enum Terrain: Hashable, Codable {
	case clear, forest, hills, mountains, swamp, desert

	var moveCost: Int {
		switch self {
		case .clear: 0
		case .forest, .hills: 1
		case .mountains: 3
		case .swamp, .desert: 2
		}
	}
}

extension State {

	mutating func moveCursor(_ direction: Direction) {
		let c = switch direction {
		case .left: cursor.neighbor(cursor.q % 2 == 0 ? 3 : 4)
		case .right: cursor.neighbor(cursor.q % 2 == 0 ? 1 : 0)
		case .down: cursor.neighbor(2)
		case .up: cursor.neighbor(5)
		}

		if c.distance(to: .zero) <= bounds { cursor = c }
	}

	mutating func endTurn() {
		guard let idx = players.firstIndex(where: { $0.id == currentPlayer }) else { return }

		let nextIdx = (idx + 1) % players.count
		currentPlayer = players[nextIdx].id
		turn = nextIdx == 0 ? turn + 1 : turn
	}

	mutating func apply(_ input: Input) {
		switch input {
		case let .direction(direction): moveCursor(direction)
		case .menu(.yes): endTurn()
		default: break
		}
	}
}

enum Direction { case left, right, down, up }
enum Target { case prev, next }
enum Action { case a, b, c, d }
enum Menu { case no, yes }

enum Input { case direction(Direction), target(Target), action(Action), menu(Menu) }

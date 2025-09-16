import HexKit

struct State {
	var cursor: Hex = .zero
	var bounds: Int = 4
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

	mutating func apply(_ input: Input) {
		switch input {
		case let .direction(direction): moveCursor(direction)
		default: break
		}
	}
}

enum Direction { case left, right, down, up }
enum Target { case prev, next }
enum Action { case a, b, c, d }
enum Menu { case no, yes }

enum Input { case direction(Direction), target(Target), action(Action), menu(Menu) }

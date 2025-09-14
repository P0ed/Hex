import HexKit

struct State {
	var cursor: Hex = .zero
}

extension State {

	mutating func moveCursor(_ direction: DPad) {
		cursor = switch direction {
		case .left: cursor.neighbor(cursor.q % 2 == 0 ? 3 : 4)
		case .right: cursor.neighbor(cursor.q % 2 == 0 ? 1 : 0)
		case .down: cursor.neighbor(2)
		case .up: cursor.neighbor(5)
		}
	}

	mutating func apply(_ action: Action) {
		switch action {
		case .direction(let dir): moveCursor(dir)
		default: break
		}
	}
}

enum DPad { case left, right, down, up }
enum Target { case prev, next }
enum Verb { case a, b, c, d }
enum Menu { case no, yes }

enum Action { case direction(DPad), target(Target), verb(Verb), menu(Menu) }

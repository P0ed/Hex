import HexKit

struct State {
	var cursor: Hex
}

extension State {

	init() {
		cursor = .zero
	}
}

extension State {

	mutating func moveCursor(_ direction: Int) {
		cursor = cursor.neighbor(direction)
	}

	mutating func apply(_ action: Action) {
		switch action {
		case .direction(.left): moveCursor(cursor.q % 2 == 0 ? 3 : 4)
		case .direction(.right): moveCursor(cursor.q % 2 == 0 ? 1 : 0)
		case .direction(.down): moveCursor(2)
		case .direction(.up): moveCursor(5)
		default: break
		}
	}
}

enum DPad {
	case left, right, down, up
}

enum Target {
	case prev, next
}

enum Verb {
	case a, b, c, d
}

enum Menu {
	case no, yes
}

enum Action {
	case direction(DPad)
	case target(Target)
	case verb(Verb)
	case menu(Menu)
}

struct ModalMenu {
	var location: Hex
	var items: [MenuItem]
	var cursor: Int = 0
	var action: MenuAction?
}

enum MenuAction {
	case close, apply((inout GameState) -> Void)
}

struct MenuItem {
	var icon: String
	var text: String
	var action: (inout GameState) -> Void
}

extension ModalMenu {

	mutating func apply(_ input: Input) {
		switch input {
		case .direction(let direction):
			moveCursor(direction)
		case .action(.a):
			action = .apply(items[cursor].action)
		case .action(.b):
			action = .close
		default: break
		}
	}

	mutating func moveCursor(_ direction: Direction) {
		switch direction {
		case .up: cursor = (cursor + 1) % items.count
		case .down: cursor = (cursor - 1 + items.count) % items.count
		default: break
		}
	}
}

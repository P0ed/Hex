struct MenuState {
	var layout: MenuLayout
	var items: [MenuItem]
	var cursor: Int = 0
	var action: MenuAction?
}

enum MenuLayout {
	case compact, inspector
}

enum MenuAction {
	case close, apply((inout GameState) -> Void)
}

struct MenuItem {
	var icon: String
	var text: String
	var description: String?
	var action: (inout GameState) -> Void
}

extension MenuState {

	var rows: Int { layout == .compact ? 1 : 3 }
	var cols: Int { layout == .inspector ? 3 : 5 }

	mutating func apply(_ input: Input) {
		switch input {
		case .direction(let direction): moveCursor(direction)
		case .action(.a): action = .apply(items[cursor].action)
		case .action(.b): action = .close
		case .index(let idx): cursor = idx
		default: break
		}
	}

	mutating func moveCursor(_ direction: Direction) {
		cursor = switch direction {
		case .down: (cursor + cols) % items.count
		case .up: (cursor - cols + items.count) % items.count
		case .right: (cursor + 1) % items.count
		case .left: (cursor - 1 + items.count) % items.count
		}
	}
}

struct HQState: ~Copyable {
	var player: Player
	var units: Speicher<16, Unit>
	var events: Speicher<16, HQEvent>
	var cursor: XY = .zero
	var camera: XY = .zero
	var selected: UID?
}

extension HQState {

	var inputable: Bool { true }
	var reducible: Bool { !events.isEmpty }
	var statusText: String { "" }

	mutating func apply(_ input: Input) {
		switch input {
		case .direction(let direction): moveCursor(direction)
		case .action(.a): processMainAction()
		default: break
		}
	}

	mutating func moveCursor(_ direction: Direction) {
		let xy = cursor.neighbor(direction)
		if HQNodes.map.contains(xy) { cursor = xy }
	}

	mutating func processMainAction() {
		if let selected {
			if selected == units[cursor]?.0 {
				self.selected = .none
			} else {
				if let (i, _) = units[cursor] {
					units[i].position = units[selected].position
					events.add(.move(i, units[i].position))
				}
				units[selected].position = cursor
				events.add(.move(selected, cursor))
				self.selected = .none
			}
		} else {
			if let (i, _) = units[cursor] {
				selected = i
			} else {

			}
		}
	}

	mutating func reduce() -> [HQEvent] {
		defer { events.erase() }
		return events.map { $1 }
	}
}

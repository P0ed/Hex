struct HQState: ~Copyable {
	var player: Player
	var units: Speicher<32, Unit>
	var events: Speicher<32, HQEvent>

	var cursor: XY = .zero
	var camera: XY = .zero
}

extension HQState {

	var inputable: Bool { true }
	var reducible: Bool { !events.isEmpty }
	var statusText: String { "" }

	mutating func apply(_ input: Input) {
		switch input {
		case .direction(let direction): moveCursor(direction)
		default: break
		}
	}

	mutating func moveCursor(_ direction: Direction) {
		let xy = cursor.neighbor(direction)
		if HQNodes.map.contains(xy) { cursor = xy }
	}

	mutating func reduce() -> [HQEvent] {
		defer { events.erase() }
		return events.map { $1 }
	}
}

struct HQState: ~Copyable {
	var player: Player
	var units: Speicher<32, Unit>
	var event: HQEvent
}

extension HQState {

	var inputable: Bool { true }
	var reducible: Bool { false }
	var statusText: String { "" }

	mutating func apply(_ input: Input) {}
	mutating func reduce() -> [HQEvent] { [] }
}

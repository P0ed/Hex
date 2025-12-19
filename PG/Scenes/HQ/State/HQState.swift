struct HQState: ~Copyable {

}

extension HQState {

	var inputable: Bool { true }
	var reducible: Bool { false }
	var statusText: String { "" }

	mutating func apply(_ input: Input) {}
	mutating func reduce() -> [Never] { [] }
}

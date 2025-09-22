struct UnitID: Hashable, Codable, ExpressibleByIntegerLiteral {
	var value: UInt32

	init(value: UInt32) {
		self.value = value
	}

	init(integerLiteral value: IntegerLiteralType) {
		self = UnitID(value: UInt32(value))
	}
}

struct PlayerID: Hashable, Codable {
	var value: UInt8
	var team: Team

	static func axis(_ id: UInt8) -> Self {
		.init(value: id, team: .axis)
	}

	static func allies(_ id: UInt8) -> Self {
		.init(value: id, team: .allies)
	}
}

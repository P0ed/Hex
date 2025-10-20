struct UnitID: RawRepresentable, Hashable, Codable, ExpressibleByIntegerLiteral {
	var rawValue: UInt16

	init(rawValue: RawValue) {
		self.rawValue = rawValue
	}

	init(integerLiteral value: IntegerLiteralType) {
		self = UnitID(rawValue: RawValue(value))
	}
}

struct PlayerID: RawRepresentable, Hashable, Codable, ExpressibleByIntegerLiteral {
	var rawValue: UInt8

	var team: Team { rawValue & 1 == 0 ? .axis : .allies }

	init(rawValue: RawValue) {
		self.rawValue = rawValue
	}

	init(integerLiteral value: IntegerLiteralType) {
		self = PlayerID(rawValue: RawValue(value))
	}

	static var deu: Self { 0 }
	static var usa: Self { 1 }
}

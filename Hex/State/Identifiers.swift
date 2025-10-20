struct UnitID: Hashable, Codable, ExpressibleByIntegerLiteral {
	var value: UInt16

	init(value: UInt16) {
		self.value = value
	}

	init(integerLiteral value: IntegerLiteralType) {
		self = UnitID(value: UInt16(value))
	}
}

struct PlayerID: Hashable, Codable, ExpressibleByIntegerLiteral {
	var value: UInt8

	var team: Team { value & 1 == 0 ? .axis : .allies }

	init(value: UInt8) {
		self.value = value
	}

	init(integerLiteral value: IntegerLiteralType) {
		self = PlayerID(value: UInt8(value))
	}

	static var deu: Self { 0 }
	static var usa: Self { 1 }
}

//struct CityID: Hashable, Codable, ExpressibleByIntegerLiteral {
//	var value: UInt8
//
//	init(value: UInt8) {
//		self.value = value
//	}
//
//	init(integerLiteral value: IntegerLiteralType) {
//		self = CityID(value: UInt8(value))
//	}
//}

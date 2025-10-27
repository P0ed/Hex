struct UnitID: RawRepresentable, Hashable, Codable, ExpressibleByIntegerLiteral {
	var rawValue: UInt16

	init(rawValue: RawValue) {
		self.rawValue = rawValue
	}

	init(integerLiteral value: IntegerLiteralType) {
		self = UnitID(rawValue: RawValue(value))
	}
}

enum PlayerID: UInt8, Hashable, Codable {
	case dnr, lnr, irn, isr, rus, swe, ukr, usa
}

extension PlayerID {

	var team: Team {
		switch self {
		case .swe, .ukr: .axis
		case .isr, .usa: .allies
		case .lnr, .dnr, .rus: .soviet
		default: .neutral
		}
	}
}

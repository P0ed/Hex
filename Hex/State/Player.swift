struct Player: Hashable, Codable {
	var country: Country
	var ai: Bool = false
	var alive: Bool = true
	var prestige: UInt16 = 0x300
	var visible: Set<XY> = []
}

enum Country: UInt8, Hashable, Codable {
	case dnr, lnr, irn, isr, rus, swe, ukr, usa
}

enum Team: UInt8, Hashable, Codable {
	case axis, allies, soviet
}

extension Country {

	var team: Team {
		switch self {
		case .swe, .ukr: .axis
		case .isr, .usa: .allies
		case .dnr, .lnr, .irn, .rus: .soviet
		}
	}
}

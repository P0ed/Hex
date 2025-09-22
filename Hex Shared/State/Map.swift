struct Map: Hashable, Codable {
	var radii: Int = 8
	var terrain: [Hex: Terrain] = [:]
	var cities: [Hex: City] = [:]

	var cells: [Hex] {
		let radii = Int(radii)
		return (-radii...radii).flatMap { q in
			(max(-radii, -q - radii)...min(radii, -q + radii)).map { r in
				Hex(q, r)
			}
		}
	}
}

struct City: Hashable, Codable {
	var name: String
	var controller: PlayerID
}

enum Terrain: Hashable, Codable {
	case field, forest, hills, mountains, swamp, desert
}

extension Terrain {

	var moveCost: Int {
		switch self {
		case .field: 0
		case .forest, .hills: 1
		case .mountains: 3
		case .swamp, .desert: 2
		}
	}

	var defBonus: Int {
		switch self {
		case .forest, .hills: 2
		case .mountains: 3
		default: 0
		}
	}
}

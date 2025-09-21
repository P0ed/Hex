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
	case clear, forest, hills, mountains, swamp, desert
}

extension Terrain {

	var moveCost: Int {
		switch self {
		case .clear: 0
		case .forest, .hills: 1
		case .mountains: 3
		case .swamp, .desert: 2
		}
	}
}

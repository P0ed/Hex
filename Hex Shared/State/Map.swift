struct Map: Hashable, Codable {
	var radii: Int
	var terrain: [Hex: Terrain] = [:]
	var cities: [Hex: City] = [:]

	var cells: [Hex] { .circle(radii) }

	subscript(_ hex: Hex) -> Terrain {
		terrain[hex] ?? .field
	}

	func converting(_ hex: Hex) -> (Int, Int) {
		(radii + hex.q, radii + hex.r + (hex.q - hex.q & 1) / 2)
	}
}

extension [Hex] {

	static func circle(_ radii: Int) -> Self {
		let _radii = -radii
		let qs = (_radii...radii)
		return qs.flatMap { q in
			let rs = Swift.max(_radii, _radii - q)...Swift.min(radii, radii - q)
			return rs.map { r in Hex(q, r) }
		}
	}
}

struct City: Hashable, Codable {
	var name: String
	var controller: PlayerID
}

enum Terrain: Hashable, Codable {
	case field, forest, hills, mountains, swamp
}

extension Terrain {

	var moveCost: Int {
		switch self {
		case .field: 1
		case .forest, .hills: 2
		case .mountains, .swamp: 3
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

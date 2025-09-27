struct Map: Hashable, Codable {
	var radius: Int
	var terrain: [Hex: Terrain] = [:]
	var cities: [Hex: City] = [:]

	var cells: [Hex] { .circle(radius) }

	subscript(_ hex: Hex) -> Terrain {
		terrain[hex] ?? .field
	}

	func converting(_ hex: Hex) -> (Int, Int) {
		(radius + hex.q, radius + hex.r + (hex.q - hex.q & 1) / 2)
	}
}

extension [Hex] {

	static func circle(_ radius: Int) -> Self {
		let _radius = -radius
		let qs = (_radius...radius)
		return qs.flatMap { q in
			let rs = Swift.max(_radius, _radius - q)...Swift.min(radius, radius - q)
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

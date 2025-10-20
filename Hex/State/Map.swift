struct Map: Hashable, Codable {
	var radius: Int
	var terrain: [Hex: Terrain] = [:]
	var cities: [Hex: City] = [:]

	var cells: [Hex] { .circle(radius) }

	subscript(_ hex: Hex) -> Terrain { terrain[hex] ?? .field }

	func contains(_ hex: Hex) -> Bool {
		hex.distance(to: .zero) <= radius
	}

	func converting(_ hex: Hex) -> (Int, Int) {
		(radius + hex.q, radius + hex.r + (hex.q - hex.q & 1) / 2)
	}

	func converting(col: Int, row: Int) -> Hex {
		return Hex(col - radius, row - (col - col & 1) / 2 - radius / 2)
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
	case city, airfield, trenches, road, river, bridge, field, forest, hills, mountains
}

extension Terrain {

	func moveCost(_ stats: Stats) -> UInt8 {
		switch stats.moveType {
		case .none: .max
		case .leg:
			switch self {
			case .city, .airfield, .road, .bridge, .field: 1
			case .forest, .hills, .trenches: min(stats.mov, 2)
			case .mountains, .river: stats.mov
			}
		case .wheel:
			switch self {
			case .city, .airfield, .road, .bridge: 1
			case .forest, .hills, .trenches, .field: 2
			case .mountains, .river: stats.mov
			}
		case .track:
			switch self {
			case .city, .airfield, .road, .bridge, .field: 1
			case .forest, .hills, .trenches: 2
			case .mountains, .river: stats.mov
			}
		}
	}

	var defBonus: UInt8 {
		switch self {
		case .forest, .hills: 1
		case .mountains, .trenches, .city: 2
		default: 0
		}
	}
}

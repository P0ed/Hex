struct Map: Hashable, Codable {
	var radius: Int
	var terrain: [Hex: Terrain] = [:]

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

enum Terrain: Hashable, Codable {
	case field, forest, hills, mountains
}

extension Terrain {

	func moveCost(_ stats: Stats) -> UInt8 {
		switch stats.moveType {
		case .leg: switch self {
		case .field: 1
		case .forest, .hills: min(stats.mov, 2)
		case .mountains: stats.mov
		}
		case .wheel: switch self {
		case .field: 2
		case .forest, .hills: 3
		case .mountains: stats.mov
		}
		case .track: switch self {
		case .field: 1
		case .forest, .hills: 2
		case .mountains: stats.mov
		}
		case .air: 1
		}
	}

	var defBonus: UInt8 {
		switch self {
		case .forest, .hills: 1
		case .mountains: 2
		default: 0
		}
	}
}

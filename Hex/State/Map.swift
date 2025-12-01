import Foundation

struct Map: ~Copyable {
	private var terrain: InlineArray<1024, Terrain>
	var size: Int

	var count: Int { size * size }

	init(size: Int) {
		precondition(size > 0 && size <= 32)
		self.size = size
		terrain = .init(repeating: .none)
	}

	var indices: AnySequence<XY> {
		AnySequence { [size, count] in
			var i = 0
			return AnyIterator {
				defer { i += 1 }
				return i < count
				? XY(i % size, i / size)
				: nil
			}
		}
	}

	subscript(xy: XY) -> Terrain {
		get { contains(xy) ? terrain[xy.x + xy.y * size] : .none }
		set { contains(xy) ? terrain[xy.x + xy.y * size] = newValue : () }
	}

	func contains(_ xy: XY) -> Bool {
		return xy.x >= 0 && xy.x < size && xy.y >= 0 && xy.y < size
	}

	func point(at xy: XY) -> CGPoint {
		xy.point + CGPoint(x: 0, y: self[xy].height)
	}
}

enum Terrain: UInt8, Hashable, Codable {
	case none, field, forest, hill, forestHill, mountain, city
}

extension Terrain {

	func moveCost(_ stats: Stats) -> UInt8 {
		switch stats.moveType {
		case .leg: switch self {
		case .field, .city: 1
		case .forest, .hill: min(stats.mov, 2)
		case .forestHill: 3
		case .mountain: stats.mov
		case .none: .max
		}
		case .wheel: switch self {
		case .city: 1
		case .field: 2
		case .forest, .hill: 3
		case .forestHill: stats.mov
		case .none, .mountain: .max
		}
		case .track: switch self {
		case .field, .city: 1
		case .forest, .hill: 2
		case .forestHill: stats.mov
		case .none, .mountain: .max
		}
		case .air: 1
		}
	}

	var defBonus: UInt8 {
		switch self {
		case .forest, .hill: 1
		case .forestHill, .mountain, .city: 2
		case .field, .none: 0
		}
	}

	var height: CGFloat {
		switch self {
		case .hill, .forestHill: 4.0
		case .mountain: 8.0
		default: 0.0
		}
	}
}

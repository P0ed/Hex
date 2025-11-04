import Foundation

struct Map: ~Copyable {
	private var terrain: InlineArray<1024, Terrain>
	var width: Int
	var height: Int

	var size: Int { width * height }

	var terrainData: Data {
		var data = Data(capacity: size)
		for xy in indices { data.append(self[xy].rawValue) }
		return data
	}

	init(width: Int, height: Int) {
		precondition(width > 0 && height > 0 && width * height <= 1024)
		self.width = width
		self.height = height
		terrain = .init(repeating: .none)
	}

	var indices: AnySequence<XY> {
		AnySequence { [size, width] in
			var i = 0
			return AnyIterator {
				defer { i += 1 }
				return i < size
				? XY(i % width, i / width)
				: nil
			}
		}
	}

	subscript(xy: XY) -> Terrain {
		get { contains(xy) ? terrain[xy.x + xy.y * width] : .none }
		set { contains(xy) ? terrain[xy.x + xy.y * width] = newValue : () }
	}

	func contains(_ xy: XY) -> Bool {
		return xy.x >= 0 && xy.x < width && xy.y >= 0 && xy.y < height
	}
}

enum Terrain: UInt8, Hashable, Codable {
	case none, field, forest, hills, mountains
}

extension Terrain {

	func moveCost(_ stats: Stats) -> UInt8 {
		switch stats.moveType {
		case .leg: switch self {
		case .field: 1
		case .forest, .hills: min(stats.mov, 2)
		case .mountains: stats.mov
		case .none: .max
		}
		case .wheel: switch self {
		case .field: 2
		case .forest, .hills: 3
		case .mountains: stats.mov
		case .none: .max
		}
		case .track: switch self {
		case .field: 1
		case .forest, .hills: 2
		case .mountains: stats.mov
		case .none: .max
		}
		case .air: 1
		}
	}

	var defBonus: UInt8 {
		switch self {
		case .forest, .hills: 1
		case .mountains: 2
		case .field, .none: 0
		}
	}
}

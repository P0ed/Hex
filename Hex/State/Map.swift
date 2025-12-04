import Foundation

struct Map<Element>: ~Copyable {
	private var terrain: InlineArray<1024, Element>
	private var zero: Element
	var size: Int

	var count: Int { size * size }

	init(size: Int, zero: Element) {
		precondition(size > 0 && size <= 32)
		self.size = size
		self.zero = zero
		terrain = .init(repeating: zero)
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

	subscript(xy: XY) -> Element {
		get { contains(xy) ? terrain[xy.x + xy.y * size] : zero }
		set { contains(xy) ? terrain[xy.x + xy.y * size] = newValue : () }
	}

	func contains(_ xy: XY) -> Bool {
		return xy.x >= 0 && xy.x < size && xy.y >= 0 && xy.y < size
	}

	func forEachEdge(_ body: (XY, Edge) -> Void) {
		Edge.allCases.forEach { edge in
			forEachEdge(edge) { xy in
				body(xy, edge)
			}
		}
	}

	func forEachEdge(_ edge: Edge, _ body: (XY) -> Void) {
		switch edge {
		case .bottom: (0 ..< size).forEach { x in body(XY(x, 0)) }
		case .left: (0 ..< size).forEach { y in body(XY(0, y)) }
		case .top: (0 ..< size).forEach { x in body(XY(x, size - 1)) }
		case .right: (0 ..< size).forEach { y in body(XY(size - 1, y)) }
		}
	}
}

extension Map<Terrain> {

	func point(at xy: XY) -> CGPoint {
		xy.point + CGPoint(x: 0, y: self[xy].height)
	}
}

enum Edge: Hashable, CaseIterable {
	case bottom, left, top, right
}

enum Terrain: UInt8, Hashable, Codable {
	case none, river, field, forest, hill, forestHill, mountain, city
}

extension Terrain {

	func moveCost(_ stats: Stats) -> UInt8 {
		switch stats.moveType {
		case .leg: switch self {
		case .field, .city: 1
		case .forest, .hill: min(stats.mov, 2)
		case .forestHill: 3
		case .river: stats.mov
		case .mountain: stats.unitType == .inf ? stats.mov : .max
		case .none: .max
		}
		case .wheel: switch self {
		case .city: 1
		case .field: 2
		case .forest, .hill: 3
		case .forestHill, .river: stats.mov
		case .none, .mountain: .max
		}
		case .track: switch self {
		case .field, .city: 1
		case .forest, .hill: 2
		case .forestHill, .river: stats.mov
		case .none, .mountain: .max
		}
		case .air: 1
		}
	}

	var defBonus: UInt8 {
		switch self {
		case .forest, .hill: 1
		case .forestHill, .mountain, .city: 2
		case .field, .river, .none: 0
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

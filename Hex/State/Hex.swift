import math_h

struct Hex: Hashable, Codable {
	private var _q: Int8
	private var _r: Int8

	var q: Int { Int(_q) }
	var r: Int { Int(_r) }
	var s: Int { -(q + r) }

	init(_ q: Int, _ r: Int) {
		_q = Int8(q)
		_r = Int8(r)
	}
}

struct XY: Hashable {
	var x: Int
	var y: Int

	init(_ x: Int, _ y: Int) {
		self.x = x
		self.y = y
	}
}

extension Hex {

	static var zero: Hex { Hex(0, 0) }

	var length: Int { (abs(q) + abs(r) + abs(s)) / 2 }

	func distance(to hex: Hex) -> Int { (self - hex).length }

	static var directions: [6 of Hex] {
		[Hex(1, 0), Hex(1, -1), Hex(0, -1), Hex(-1, 0), Hex(-1, 1), Hex(0, 1)]
	}

	var neighbors: [6 of Hex] {
		Self.directions.map { x in x + self }
	}

	func neighbor(_ neighbor: HexNeighbor) -> Hex {
		self + Self.directions[Int(neighbor.rawValue % 6)]
	}

	func neighbor(_ direction: Direction) -> Hex {
		switch direction {
		case .left: neighbor(q & 1 == 0 ? .northWest : .southWest)
		case .right: neighbor(q & 1 == 0 ? .northEast : .southEast)
		case .down: neighbor(.south)
		case .up: neighbor(.north)
		}
	}

	func circle(_ radius: Int) -> [Hex] {
		[Hex].circle(radius).map { x in x + self }
	}

	static func + (lhs: Hex, rhs: Hex) -> Hex {
		Hex(lhs.q + rhs.q, lhs.r + rhs.r)
	}

	static func - (lhs: Hex, rhs: Hex) -> Hex {
		Hex(lhs.q - rhs.q, lhs.r - rhs.r)
	}

	var pt: Point {
		Point(1.5 * Double(q), (0.5 * Double(q) + Double(r)) * .s3)
	}

	var corners: [Point] {
		(0..<6).map { [pt] c in pt + .hexCorner(c) }
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

enum HexNeighbor: UInt8, Hashable {
	case northEast, southEast, south, southWest, northWest, north
}

struct Point: Hashable {
	var x: Double
	var y: Double

	init(_ x: Double, _ y: Double) {
		self.x = x
		self.y = y
	}
}

extension Point {

	static var zero: Point { Point(0, 0) }

	var length: Double { sqrt(x * x + y * y) }

	static func + (lhs: Point, rhs: Point) -> Point {
		Point(lhs.x + rhs.x, lhs.y + rhs.y)
	}

	static func - (lhs: Point, rhs: Point) -> Point {
		Point(lhs.x - rhs.x, lhs.y - rhs.y)
	}

	static func * (lhs: Point, rhs: Double) -> Point {
		Point(lhs.x * rhs, lhs.y * rhs)
	}

	static func hexCorner(_ corner: Int) -> Point {
		let a = .pi * Double(corner) / 3.0
		return Point(cos(a), sin(a))
	}
}

extension Double {
	static var s2: Double { sqrt(2.0) }
	static var s3: Double { sqrt(3.0) }
}

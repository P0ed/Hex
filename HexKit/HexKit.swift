import math_h

let s2 = Double(2.0).squareRoot()
let s3 = Double(3.0).squareRoot()

public struct Hex: Hashable {
	public var q: Int
	public var r: Int
	public var s: Int { -(q + r) }

	public init(_ q: Int, _ r: Int) {
		self.q = q
		self.r = r
	}
}

public extension Hex {

	static var zero: Hex { Hex(0, 0) }

	var length: Int { (abs(q) + abs(r) + abs(s)) / 2 }

	func distance(to hex: Hex) -> Int { (self - hex).length }

	static var directions: [Hex] {
		[Hex(1, 0), Hex(1, -1), Hex(0, -1), Hex(-1, 0), Hex(-1, 1), Hex(0, 1)]
	}

	var neighbors: [Hex] {
		Self.directions.map { self + $0 }
	}

	func neighbor(_ d: Int) -> Hex {
		self + Self.directions[((d % 6) + 6) % 6]
	}

	static func + (lhs: Hex, rhs: Hex) -> Hex {
		Hex(lhs.q + rhs.q, lhs.r + rhs.r)
	}

	static func - (lhs: Hex, rhs: Hex) -> Hex {
		Hex(lhs.q - rhs.q, lhs.r - rhs.r)
	}

	static func * (lhs: Hex, rhs: Int) -> Hex {
		Hex(lhs.q * rhs, lhs.r * rhs)
	}

	var cartesian: Point {
		Point(1.5 * Double(q), s3 * 0.5 * Double(q) + s3 * Double(r))
	}

	var corners: [Point] {
		(0..<6).map { [cartesian] in cartesian + .hexCorner($0) }
	}
}

public struct Map {
	public var cells: [Hex]

	public init(cells: [Hex]) {
		self.cells = cells
	}

	public init(hex: Int) {
		self = Map(cells: (-hex..<hex).flatMap { q in
			(max(-hex, -q - hex)..<min(hex, -q + hex)).map { r in
				Hex(q, r)
			}
		})
	}
}

public struct Point: Hashable {
	public var x: Double
	public var y: Double

	public init(_ x: Double, _ y: Double) {
		self.x = x
		self.y = y
	}
}

public extension Point {

	static var zero: Point { Point(0, 0) }

	var length: Double { (x * x + y * y).squareRoot() }

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
		let a = 2.0 * .pi * Double(corner) / 6
		return Point(cos(a), sin(a))
	}
}

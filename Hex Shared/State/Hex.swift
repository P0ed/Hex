import math_h

struct Hex: Hashable, Codable {
	private var _q: Int16
	private var _r: Int16

	var q: Int { Int(_q) }
	var r: Int { Int(_r) }
	var s: Int { -(q + r) }

	init(_ q: Int, _ r: Int) {
		_q = Int16(q)
		_r = Int16(r)
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
		Self.directions.map { $0 + self }
	}

	func neighbor(_ d: Int) -> Hex {
		self + Self.directions[d % 6]
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
		Point(1.5 * Double(q), .s3 * 0.5 * Double(q) + .s3 * Double(r))
	}

	var corners: [Point] {
		(0..<6).map { [cartesian] in cartesian + .hexCorner($0) }
	}
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

extension InlineArray {

	func map(_ transform: (Element) -> Element) -> Self {
		var arr = self
		for i in self.indices { arr[i] = transform(arr[i]) }
		return arr
	}

	func mapInPlace(_ transform: (inout Element) -> Void) -> Self {
		var arr = self
		for i in self.indices { transform(&arr[i]) }
		return arr
	}
}

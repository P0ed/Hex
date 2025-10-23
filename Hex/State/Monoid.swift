func identity<A>(_ x: A) -> A { x }

func modifying<A>(_ value: A, _ tfm: (inout A) -> Void) -> A {
	var value = value
	tfm(&value)
	return value
}

protocol Monoid {
	static var empty: Self { get }
	mutating func combine(_ other: Self)
}

infix operator ><

extension Monoid {

	static func make(_ tfm: (inout Self) -> Void) -> Self {
		modifying(.empty, tfm)
	}

	func combined(_ other: Self) -> Self {
		modifying(self, { m in m.combine(other) })
	}

	static func >< (_ lhs: Self, rhs: Self) -> Self {
		lhs.combined(rhs)
	}
}

extension Set: Monoid {
	static var empty: Set { [] }
	mutating func combine(_ other: Set) { formUnion(other) }
}

extension Array: Monoid {
	static var empty: Array { [] }
	mutating func combine(_ other: Array) { self += other }
}

extension String: Monoid {
	static var empty: String { "" }
	mutating func combine(_ other: String) { self += other }
}

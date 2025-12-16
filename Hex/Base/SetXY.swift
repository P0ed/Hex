struct SetXY {
	private var storage: InlineArray<32, UInt32>
}

extension SetXY: Monoid {

	static var empty: Self {
		.init(storage: .init(repeating: 0))
	}

	mutating func combine(_ other: Self) {
		formUnion(other)
	}
}

extension SetXY: Equatable {

	static func == (lhs: Self, rhs: Self) -> Bool {
		for i in lhs.storage.indices where lhs.storage[i] != rhs.storage[i] {
			return false
		}
		return true
	}
}

private extension XY {

	var inBounds: Bool {
		x >= 0 && x < 32 && y >= 0 && y < 32
	}
}

extension SetXY {

	var set: Set<XY> {
		.make { set in
			for y in storage.indices where storage[y] != 0 {
				for x in storage.indices {
					let xy = XY(x, y)
					if self[xy] { set.insert(xy) }
				}
			}
		}
	}

	init(_ xys: [XY]) {
		self = .empty
		for xy in xys { self[xy] = true }
	}

	subscript(_ xy: XY) -> Bool {
		get {
			guard xy.inBounds else { return false }
			return storage[xy.y] & 1 << xy.x != 0
		}
		set {
			guard xy.inBounds else { return }
			if newValue {
				storage[xy.y] |= 1 << xy.x
			} else {
				storage[xy.y] &= ~(1 << xy.x)
			}
		}
	}

	mutating func formUnion(_ set: Self) {
		for i in storage.indices {
			storage[i] |= set.storage[i]
		}
	}

	func union(_ xys: [XY]) -> Self {
		var result = self
		for xy in xys { result[xy] = true }
		return result
	}

	func subtracting(_ xys: [XY]) -> Self {
		var result = self
		for xy in xys { result[xy] = false }
		return result
	}
}

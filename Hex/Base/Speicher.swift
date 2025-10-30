protocol DeadOrAlive {
	static var dead: Self { get }
	var alive: Bool { get }
}

struct Speicher<let maxCount: Int, Element: DeadOrAlive>: ~Copyable {
	private var elements: InlineArray<maxCount, Element>
	private(set) var count: Int
}

extension Speicher {

	init() {
		elements = .init(repeating: .dead)
		count = 0
	}

	init(array: [Element]) {
		precondition(array.count <= maxCount)
		count = array.count
		elements = .init { [count] i in
			i < count ? array[i] : .dead
		}
	}

	var indices: CountableRange<Int> {
		0..<count
	}

	subscript(_ index: Int) -> Element {
		get { elements[index] }
		set { elements[index] = newValue }
	}

	mutating func add(_ element: Element) -> Int {
		for i in indices where !elements[i].alive {
			elements[i] = element
			return i
		}
		defer { count += 1 }
		elements[count] = element
		return count
	}

	func forEach(_ body: (Int, Element) -> Void) {
		for i in indices where elements[i].alive { body(i, elements[i]) }
	}

	func map<A>(_ transform: (Int, Element) -> A) -> [A] {
		var array = [] as [A]
		array.reserveCapacity(count)
		for i in indices where elements[i].alive {
			array.append(transform(i, elements[i]))
		}
		return array
	}

	func compactMap<A>(_ transform: (Int, Element) -> A?) -> [A] {
		var array = [] as [A]
		for i in indices where elements[i].alive {
			if let value = transform(i, elements[i]) {
				array.append(value)
			}
		}
		return array
	}

	func reduce<R>(into result: R, _ fold: (inout R, UID, Element) -> Void) -> R {
		var result = result
		for i in indices where elements[i].alive {
			fold(&result, i, elements[i])
		}
		return result
	}

	func firstMap<A>(_ transform: (Int, Element) -> A?) -> A? {
		for i in indices where elements[i].alive {
			if let some = transform(i, elements[i]) { return some }
		}
		return nil
	}
}

extension Speicher where Element == Unit {

	subscript(_ hex: Hex) -> (UID, Unit)? {
		firstMap { i, u in u.position == hex ? (i, u) : nil }
	}
}

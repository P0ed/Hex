extension InlineArray {

	func mapInPlace(_ transform: (inout Element) -> Void) -> Self {
		var arr = self
		for i in indices { transform(&arr[i]) }
		return arr
	}

	func map(_ transform: (Element) -> Element) -> Self {
		var arr = self
		for i in indices { arr[i] = transform(arr[i]) }
		return arr
	}

	func map<A>(_ transform: (Element) -> A) -> [A] {
		var arr = [] as [A]
		arr.reserveCapacity(count)
		for i in indices { arr.append(transform(self[i])) }
		return arr
	}

	func firstMap<A>(_ transform: (Element) -> A?) -> A? {
		for i in indices {
			if let some = transform(self[i]) { return some }
		}
		return nil
	}
}

extension Sequence {

	func firstMap<A>(_ transform: (Element) -> A?) -> A? {
		for e in self {
			if let some = transform(e) { return some }
		}
		return nil
	}
}

extension Array {

	init<let count: Int>(_ inlineArray: InlineArray<count, Element>) {
		var arr = [] as Self
		arr.reserveCapacity(count)
		for idx in inlineArray.indices { arr.append(inlineArray[idx]) }
		self = arr
	}

	func mapInPlace(_ transform: (inout Element) -> Void) -> Self {
		map { e in modifying(e, transform) }
	}

	mutating func fastRemove(at index: Int) {
		let last = count - 1
		if index != last { self[index] = self[last] }
		remove(at: last)
	}

	subscript(_ ref: Ref<Element>) -> Element {
		get { self[ref.index] }
		set { self[ref.index] = newValue }
	}
}

struct Ref<Element> {
	var index: Int
}

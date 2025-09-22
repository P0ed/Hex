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

extension Array {

	mutating func mapInPlace(_ tfm: (inout Element) -> Void) -> Self {
		map { e in modifying(e, tfm) }
	}
}

func modifying<A>(_ value: A, _ tfm: (inout A) -> Void) -> A {
	var value = value
	tfm(&value)
	return value
}

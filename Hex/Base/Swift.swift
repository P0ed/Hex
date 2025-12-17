func id<A>(_ x: A) -> A { x }
func ø<each A>(_ x: repeat each A) {}

func modifying<A>(_ value: A, _ tfm: (inout A) -> Void) -> A {
	var value = value
	tfm(&value)
	return value
}

func clone<A: ~Copyable>(_ x: borrowing A) -> A {
	withUnsafeTemporaryAllocation(
		byteCount: MemoryLayout<A>.size,
		alignment: MemoryLayout<A>.alignment
	) { raw in
		withUnsafePointer(to: x) { src in
			raw.baseAddress!.copyMemory(
				from: src,
				byteCount: MemoryLayout<A>.size
			)
		}
		return raw.baseAddress!
			.assumingMemoryBound(to: A.self)
			.move()
	}
}

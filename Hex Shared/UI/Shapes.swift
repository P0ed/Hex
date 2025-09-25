import SpriteKit

extension SKShapeNode {

	convenience init(hex: Hex, base: SKColor, line: SKColor) {
		self.init(path: .hex)
		position = hex.point
		fillColor = base
		strokeColor = line
	}
}

extension CGPath {

	static func make(_ transform: (CGMutablePath) -> Void) -> CGPath {
		let path = CGMutablePath()
		transform(path)
		return path
	}

	static var hex: CGPath {
		.make { path in
			path.addLines(between: Hex.zero.corners.map { ($0 * .hexSize).cg })
			path.closeSubpath()
		}
	}
}

extension Point {
	var cg: CGPoint { .init(x: x, y: y) }
}

extension Hex {
	var point: CGPoint { (cartesian * .hexSize).cg }
}

extension Double {
	static var hexSize: Double { 24.0 }
}

extension CGSize {
	static var hex: CGSize { .init(width: 2 * .hexSize, height: 2 * .hexSize) }
}

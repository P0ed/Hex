import SpriteKit

extension SKShapeNode {

	convenience init(hex: Hex, base: SKColor, line: SKColor) {
		self.init(path: .make { path in
			let corners = hex.corners
			path.move(to: (corners[5] * .hexSize).cg)
			corners.forEach { corner in
				path.addLine(to: (corner * .hexSize).cg)
			}
		})
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

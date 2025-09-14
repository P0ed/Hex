import HexKit
import SpriteKit

extension SKShapeNode {

	convenience init(hex: Hex, size: Double) {
		self.init(path: .make { path in
			let corners = hex.corners
			path.move(to: (corners[5] * size).cg)
			corners.forEach { corner in
				path.addLine(to: (corner * size).cg)
			}
		})
	}
}

extension CGPath {

	static func make(_ tfm: (CGMutablePath) -> Void) -> CGPath {
		let path = CGMutablePath()
		tfm(path)
		return path
	}
}

extension Point {
	var cg: CGPoint { .init(x: x, y: y) }
}

extension Double {

	static var hexSize: Double { 24.0 }
}

import SpriteKit

extension SKColor {
	static var baseSelection: SKColor { .init(white: 0.33, alpha: 0.47) }
	static var baseCursor: SKColor { .init(white: 0.22, alpha: 0.33) }

	static var lineSelection: SKColor { .init(white: 0.22, alpha: 0.47) }
	static var lineCursor: SKColor { .init(white: 0.33, alpha: 0.82) }

	static var textDefault: SKColor { .init(white: 0.01, alpha: 1.0) }
}

extension SKShapeNode {

	convenience init(hex: Hex, base: SKColor, line: SKColor) {
		self.init(path: .hex)
		position = hex.point
		fillColor = base
		strokeColor = line
	}
}

extension SKLabelNode {

	enum Size: UInt8 {
		case s = 14
		case m = 16
		case l = 22
	}

	convenience init(size: Size, color: SKColor = .white) {
		self.init()
		fontName = "Menlo"
		fontSize = CGFloat(size.rawValue)
		fontColor = color
		setScale(0.5)
	}
}

extension SKAudioNode {

	func play() {
		removeAllActions()
		run(.play())
	}
}

extension SKAction {

	static func hit() -> SKAction {
		.sequence([
			.scale(to: 0.9, duration: 0.1),
			.scale(to: 1.0, duration: 0.1)
		])
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
			path.addLines(between: Hex.zero.corners.map { pt in (pt * .hexR).cg })
			path.closeSubpath()
		}
	}
}

extension Point {
	var cg: CGPoint { .init(x: x, y: y) }
}

extension Hex {
	var point: CGPoint { (pt * .hexR).cg }
}

extension Double {
	static var hexR: Double { 32.0 }
}

extension CGSize {
	static var hex: CGSize { .init(width: 2.0 * Double.hexR, height: 2.0 * Double.hexR) }
}

import SpriteKit

extension SKColor {
	static var baseCell: SKColor { .init(white: 0.02, alpha: 0.02) }
	static var baseSelection: SKColor { .init(white: 0.33, alpha: 0.5) }
	static var baseCursor: SKColor { .init(white: 0.1, alpha: 0.1) }

	static var lineCell: SKColor { .init(white: 0.15, alpha: 1.0) }
	static var lineSelection: SKColor { .init(white: 0.22, alpha: 0.5) }
	static var lineCursor: SKColor { .init(white: 0.33, alpha: 0.82) }

	static var textDefault: SKColor { .init(white: 0.01, alpha: 1.0) }
}

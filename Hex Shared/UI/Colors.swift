import SpriteKit

extension SKColor {
	static var baseCell: SKColor { .init(white: 0.02, alpha: 1.0) }
	static var baseSelection: SKColor { .init(white: 0.12, alpha: 0.5) }
	static var baseCursor: SKColor { .init(white: 0.16, alpha: 0.5) }

	static var lineCell: SKColor { .init(white: 0.12, alpha: 1.0) }
	static var lineSelection: SKColor { .init(white: 0.24, alpha: 0.5) }
	static var lineCursor: SKColor { .init(white: 0.32, alpha: 0.5) }
}

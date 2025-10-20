import SpriteKit

extension SKAction {

	static func hit() -> SKAction {
		.sequence([
			.scale(to: 0.9, duration: 0.1),
			.scale(to: 1.0, duration: 0.1)
		])
	}
}

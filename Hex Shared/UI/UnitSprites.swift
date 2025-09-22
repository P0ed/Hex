import SpriteKit

@MainActor
extension Unit {

	var sprite: SKNode {
		let node = SKNode()
		let sprite = SKSpriteNode(imageNamed: imageName)
		sprite.xScale = player.team == .axis ? 0.5 : -0.5
		sprite.yScale = 0.5
		node.addChild(sprite)
		node.position = position.point
		node.zPosition = 3.0
		return node
	}

	private var imageName: String {
		switch stats.typ {
		case .inf: "Inf"
		case .recon: "Recon"
		case .tank: "Tank"
		case .art: "Art"
		case .antiAir: "AA"
		case .air: "Fighter"
		}
	}
}

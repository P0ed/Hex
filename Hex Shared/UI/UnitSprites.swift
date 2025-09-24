import SpriteKit

@MainActor
extension Unit {

	var sprite: SKNode {
		let node = SKNode()
		node.position = position.point
		node.zPosition = 4.0

		let sprite = SKSpriteNode(imageNamed: imageName)
		sprite.xScale = player.team == .axis ? 0.5 : -0.5
		sprite.yScale = 0.5
		node.addChild(sprite)

		let label = SKLabelNode(fontNamed: "Menlo")
		label.name = "hp"
		label.position = CGPoint(x: 0, y: .hexSize * -0.8)
		label.fontSize = CGFloat(Double.hexSize * 0.28)
		label.fontColor = .textDefault
		label.text = "\(hp.value)"
		node.addChild(label)

		return node
	}

	private var imageName: String {
		switch stats.typ {
		case .inf: "Inf 39"
		case .recon: "LT"
		case .tank: "Tank"
		case .art: "Art"
		case .antiAir: "AA"
		case .air: "Fighter"
		}
	}
}

extension SKNode {

	var unitHP: SKLabelNode? {
		childNode(withName: "hp") as? SKLabelNode
	}

	func update(_ unit: Unit) {
		unitHP?.text = "\(unit.hp.value)"
	}
}

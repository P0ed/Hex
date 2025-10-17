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
		sprite.texture?.filteringMode = .nearest
		node.addChild(sprite)

		let plate = SKSpriteNode(imageNamed: "Plate")
		plate.position = CGPoint(x: 0, y: -20.5)
		plate.zPosition = 5.0
		plate.texture?.filteringMode = .nearest
		node.addChild(plate)

		let label = SKLabelNode(fontNamed: "Menlo")
		label.name = "hp"
		label.fontSize = 8.0
		label.fontColor = .textDefault
		label.text = "\(stats.hp)"
		label.position = CGPoint(x: 0, y: -24.5)
		label.zPosition = 6.0
		node.addChild(label)

		return node
	}

	var imageName: String {
		switch stats.unitType {
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
		unitHP?.text = "\(unit.stats.hp)"
	}
}

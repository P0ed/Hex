import SpriteKit

@MainActor
extension Unit {

	var sprite: SKNode {
		let node = SKNode()
		node.position = position.point
		node.zPosition = 4.0

		let sprite = SKSpriteNode(imageNamed: imageName)
		sprite.xScale = player.team == .axis ? 1.0 : -1.0
		sprite.texture?.filteringMode = .nearest
		node.addChild(sprite)

		let plate = SKSpriteNode(imageNamed: "Plate")
		plate.position = CGPoint(x: 0, y: -20.5)
		plate.zPosition = 0.1
		plate.texture?.filteringMode = .nearest
		node.addChild(plate)

		let label = SKLabelNode(size: .m, color: .textDefault)
		label.name = "hp"
		label.fontColor = .textDefault
		label.text = "\(stats.hp)"
		label.position = CGPoint(x: 0, y: -24.5)
		label.zPosition = 0.2
		node.addChild(label)

		return node
	}

	var imageName: String {
		switch stats.unitType {
		case .inf: "Inf"
		case .recon: "Recon"
		case .tank: "Tank"
		case .art: "Art"
		case .antiAir: "AA"
		case .air: "Fighter"
		case .engineer: "Crane"
		case .building: "Mammut"
		}
	}
}

@MainActor
extension BuildingType {

	var tile: SKTileGroup {
		switch self {
		case .city: .city
		case .radar: .mammut
		default: .city
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

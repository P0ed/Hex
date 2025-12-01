import SpriteKit

@MainActor
extension Unit {

	var sprite: SKNode {
		let node = SKNode()

		let sprite = SKSpriteNode(imageNamed: imageName)
		sprite.xScale = country.team == .axis ? 1.0 : -1.0
		sprite.texture?.filteringMode = .nearest
		node.addChild(sprite)

		let plate = SKSpriteNode(imageNamed: "Plate")
		plate.position = CGPoint(x: 0, y: -14.5)
		plate.zPosition = 2.1
		plate.texture?.filteringMode = .nearest
		node.addChild(plate)

		let label = SKLabelNode(size: .m, color: .textDefault)
		label.name = "hp"
		label.text = "\(stats.hp)"
		label.position = CGPoint(x: 0, y: -20.0)
		label.zPosition = 2.2
		node.addChild(label)

		return node
	}

	var imageName: String {
		switch stats.unitType {
		case .inf: country.team == .axis ? "Inf-Axis" : "Inf"
		case .recon: "Recon"
		case .tank: "Tank"
		case .art: "Art"
		case .antiAir: "AA"
		case .air: "Fighter"
		case .engineer: "Engi"
		case .supply: "Truck"
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

	func showSight(for duration: TimeInterval) {
		let sight = SKSpriteNode(imageNamed: "Sight")
		sight.texture?.filteringMode = .nearest
		addChild(sight)

		sight.run(.sequence([
			.wait(forDuration: duration),
			.removeFromParent()
		]))
	}
}

@MainActor
extension BuildingType {

	var imageName: String {
		switch self {
		case .city: "City"
		}
	}

	var tile: SKTileGroup {
		switch self {
		case .city: .city
		}
	}
}

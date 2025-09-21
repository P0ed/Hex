import SpriteKit

final class GameScene: SKScene {
	private var state: State = .initial {
		didSet { didSetState() }
	}

	private var cursor: SKShapeNode?
	private var units: [UnitID: SKSpriteNode] = [:]

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFill

		addCamera()
		addMap()
		addCursor()

		state.events = state.units.map { .spawn($0.id) }
	}

	func didSetState() {
		cursor?.position = (state.cursor.cartesian * .hexSize).cg

		if state.events.isEmpty { return }
		state.events.forEach(processEvent)
		state.events = []
	}

	private func processEvent(_ event: Event) {
		switch event {
		case let .spawn(uid):
			if let unit = state[uid] {
				addChild(unit.sprite)
			}
		case let .move(src, pos):
			units[src]?.run(.move(to: (pos.cartesian * .hexSize).cg, duration: 0.1))
		case let .attack(src, dst):
			units[src]?.run(.hit(), completion: { [units] in units[dst]?.run(.hit()) })
		}
	}

	private func addCamera() {
		let camera = SKCameraNode()
		addChild(camera)
		self.camera = camera
	}

	private func addMap() {
		state.map.cells.forEach { hex in
			let cell = SKShapeNode(hex: hex, size: .hexSize)
			cell.strokeColor = .lineCell
			cell.fillColor = .baseCell
			addChild(cell)
		}
	}

	private func addCursor() {
		let cursor = SKShapeNode(hex: .zero, size: .hexSize)
		cursor.strokeColor = .lineCursor
		cursor.fillColor = .baseCursor
		cursor.zPosition = 1.0
		addChild(cursor)
		self.cursor = cursor

		camera?.constraints = [.distance(.init(upperLimit: 200), to: cursor)]
	}
}

extension SKAction {

	static func hit() -> SKAction {
		.group([
			.scale(to: 0.9, duration: 0.1),
			.scale(to: 1.0, duration: 0.1)
		])
	}
}

@MainActor
extension Unit {

	var sprite: SKSpriteNode {
		let sprite = SKSpriteNode(imageNamed: "Inf")
		sprite.xScale = player.team == .axis ? 1 : -1
		sprite.position = (position.cartesian * .hexSize).cg
		sprite.zPosition = 1.0
		return sprite
	}
}

extension State {

	@MainActor
	static var initial: State {
		.init(
			map: Map(),
			players: [
				.init(id: .axis(0), money: 100),
				.init(id: .allies(0), money: 100)
			],
			units: [
				.infantry(player: .axis(0), position: .zero),
				.infantry(player: .allies(0), position: .zero.neighbor(5).neighbor(5))
			]
		)
	}
}

#if os(OSX)
extension GameScene {

	override func keyDown(with event: NSEvent) {
		switch event.specialKey {
		case .leftArrow: state.apply(.direction(.left))
		case .rightArrow: state.apply(.direction(.right))
		case .downArrow: state.apply(.direction(.down))
		case .upArrow: state.apply(.direction(.up))
		default: break
		}
		switch event.characters {
		case "q": state.apply(.target(.prev))
		case "r": state.apply(.target(.next))
		case "w": state.apply(.menu(.no))
		case "e": state.apply(.menu(.yes))
		case "a": state.apply(.action(.a))
		case "s": state.apply(.action(.b))
		case "d": state.apply(.action(.c))
		case "f": state.apply(.action(.d))
		case "m": camera?.run(.scale(to: 4.0, duration: 0.33))
		case "z": camera?.run(.scale(to: (camera?.xScale ?? 1.0) > 2.0 ? 1.0 : 4.0, duration: 0.33))
		default: break
		}
	}

	override func keyUp(with event: NSEvent) {
		switch event.characters {
		case "m": camera?.run(.scale(to: 1.0, duration: 0.33))
		default: break
		}
	}
}
#endif

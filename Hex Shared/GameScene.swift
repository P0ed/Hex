import HexKit
import SpriteKit

final class GameScene: SKScene {
	private var dirty = false
	private var state: State = .initial { didSet { dirty = true } }

	private var cursor: SKShapeNode?

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFill

		addCamera()
		addMap(Map(hex: state.bounds))
		addCursor()
	}

	override func update(_ currentTime: TimeInterval) {
		guard dirty else { return }
		defer { dirty = false }
		cursor?.position = (state.cursor.cartesian * .hexSize).cg
	}

	private func addCamera() {
		let camera = SKCameraNode()
		addChild(camera)
		self.camera = camera
	}

	private func addMap(_ map: Map) {
		map.cells.forEach { hex in
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

extension State {

	@MainActor
	static var initial: State {
		.init(
			players: [.init(id: 0, team: .left, money: 100), .init(id: 1, team: .right, money: 100)],
			currentPlayer: 0,
			units: [
				.infantry(player: 0, position: .zero)
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

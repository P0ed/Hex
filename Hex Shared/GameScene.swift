import HexKit
import SpriteKit

final class GameScene: SKScene {
	private var dirty = false
	private var state: State = .init() {
		didSet { dirty = true }
	}

	private var cursor: SKShapeNode?

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFill
		anchorPoint = CGPoint(x: 0.5, y: 0.5)

		let cursor = SKShapeNode(hex: .zero, size: .hexSize)
		cursor.strokeColor = .lineCursor
		cursor.fillColor = .baseCursor
		addChild(cursor)
		self.cursor = cursor
	}

	override func update(_ currentTime: TimeInterval) {
		guard dirty else { return }
		dirty = false
		cursor?.position = (state.cursor.cartesian * .hexSize).cg
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
	}

	override func keyUp(with event: NSEvent) {}
}
#endif

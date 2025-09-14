import HexKit
import SpriteKit

final class GameScene: SKScene {
	private var dirty = false
	private var state: State = .init() {
		didSet { dirty = true }
	}
	private var cursor: SKShapeNode?

	static func newGameScene() -> GameScene {
		let scene = GameScene(size: CGSize(width: 1280, height: 800))
		scene.scaleMode = .aspectFill
		return scene
	}

	func setUpScene() {
		let cursor = SKShapeNode(hex: .zero, size: .hexSize)
		cursor.lineWidth = 2.0
		cursor.strokeColor = .lineCursor
		cursor.fillColor = .baseCursor
		addChild(cursor)
		self.cursor = cursor
	}

	override func didMove(to view: SKView) {
		self.setUpScene()
	}

	override func update(_ currentTime: TimeInterval) {
		if dirty {
			dirty = false
			cursor?.position = (state.cursor.cartesian * .hexSize).cg
		}
	}
}

#if os(iOS) || os(tvOS)
extension GameScene {

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			self.makeSpinny(at: t.location(in: self), color: SKColor.green)
		}
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
		}
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			self.makeSpinny(at: t.location(in: self), color: SKColor.red)
		}
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			self.makeSpinny(at: t.location(in: self), color: SKColor.red)
		}
	}
}
#endif

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

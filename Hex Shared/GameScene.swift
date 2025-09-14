import SpriteKit

final class GameScene: SKScene {
	fileprivate var spinnyNode: SKShapeNode?

	static func newGameScene() -> GameScene {
		let scene = GameScene(size: CGSize(width: 1280, height: 800))
		scene.scaleMode = .aspectFill
		return scene
	}

	func setUpScene() {
		let w = (self.size.width + self.size.height) * 0.05
		self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)

		if let spinnyNode = self.spinnyNode {
			spinnyNode.lineWidth = 4.0
			spinnyNode.run(.repeatForever(
				.rotate(byAngle: .pi, duration: 1)
			))
			spinnyNode.run(.sequence([
				.wait(forDuration: 0.5),
				.fadeOut(withDuration: 0.5),
				.removeFromParent()
			]))
		}
	}

	override func didMove(to view: SKView) {
		self.setUpScene()
	}

	func makeSpinny(at pos: CGPoint, color: SKColor) {
		if let spinny = self.spinnyNode?.copy() as? SKShapeNode {
			spinny.position = pos
			spinny.strokeColor = color
			self.addChild(spinny)
		}
	}

	override func update(_ currentTime: TimeInterval) {

	}
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		if let label = self.label {
			label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
		}

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
// Mouse-based event handling
extension GameScene {

	override func mouseDown(with event: NSEvent) {
		self.makeSpinny(at: event.location(in: self), color: SKColor.green)
	}

	override func mouseDragged(with event: NSEvent) {
		self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
	}

	override func mouseUp(with event: NSEvent) {
		self.makeSpinny(at: event.location(in: self), color: SKColor.red)
	}
}
#endif

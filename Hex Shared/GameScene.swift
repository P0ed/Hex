import HexKit
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
		self.spinnyNode = SKShapeNode(hex: .zero, size: w)

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
		self.makeSpinny(at: event.location(in: self), color: .green)
	}

	override func mouseDragged(with event: NSEvent) {
		self.makeSpinny(at: event.location(in: self), color: .blue)
	}

	override func mouseUp(with event: NSEvent) {
		self.makeSpinny(at: event.location(in: self), color: .red)
	}

	override func keyDown(with event: NSEvent) {
		
	}

	override func keyUp(with event: NSEvent) {

	}
}
#endif

extension SKShapeNode {

	convenience init(hex: Hex, size: Double) {
		self.init(path: .make { path in
			let corners = hex.corners
			path.move(to: (corners[5] * size).cg)
			corners.forEach { corner in
				path.addLine(to: (corner * size).cg)
			}
		})
	}
}

extension CGPath {

	static func make(_ tfm: (CGMutablePath) -> Void) -> CGPath {
		let path = CGMutablePath()
		tfm(path)
		return path
	}
}

extension Point {
	var cg: CGPoint { .init(x: x, y: y) }
}

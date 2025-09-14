import Cocoa
import SpriteKit
import GameplayKit

final class GameViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		let scene = GameScene.newGameScene()

		let skView = self.view as! SKView
		skView.presentScene(scene)
		skView.ignoresSiblingOrder = true
		skView.showsFPS = true
		skView.showsNodeCount = true
	}
}

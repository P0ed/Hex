import UIKit
import SpriteKit
import GameplayKit

final class GameViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		let scene = GameScene(size: CGSize(width: 1024.0, height: 768.0))

		let skView = self.view as! SKView
		skView.presentScene(scene)
		skView.ignoresSiblingOrder = true
		skView.showsFPS = true
		skView.showsNodeCount = true
	}
}

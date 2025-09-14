import Cocoa
import SpriteKit
import GameplayKit

final class GameViewController: NSViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		guard let view = self.view as? SKView else { return }
		view.presentScene(GameScene(size: sceneSize))
		view.ignoresSiblingOrder = true
		view.showsFPS = true
		view.showsNodeCount = true
	}

	override func viewDidLayout() {
		super.viewDidLayout()
		(view as? SKView)?.scene?.size = sceneSize
	}

	private var sceneSize: CGSize {
		CGSize(
			width: view.frame.width / 2.0,
			height: view.frame.height / 2.0
		)
	}
}

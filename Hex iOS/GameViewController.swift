import UIKit
import SpriteKit
import GameplayKit

final class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

		guard let view = view as? SKView else { return }

		view.presentScene(GameScene(size: sceneSize))
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            .allButUpsideDown
        } else {
            .all
        }
    }

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		(view as? SKView)?.scene?.size = sceneSize
	}

    override var prefersStatusBarHidden: Bool { true }

	private var sceneSize: CGSize {
		CGSize(
			width: view.frame.width / 2.0,
			height: view.frame.height / 2.0
		)
	}
}

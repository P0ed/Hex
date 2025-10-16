import SpriteKit
import GameplayKit

final class GameScene: SKScene {
	private(set) var state: GameState = .random()
	{ didSet { didSetState(oldValue: oldValue) } }

	private(set) var nodes: BattlefieldNodes?

	private let hid = HIDController()

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFill

		nodes = BattlefieldNodes(
			cursor: addCursor(),
			map: addMap(state.map)
		)
		camera = addCamera()
		state.initialize()

		hid.inputStream = { [weak self] input in self?.state.apply(input) }
	}

	func applyInput(_ input: Input) {
		state.apply(input)
	}

	func addUnit(_ uid: UnitID, node: SKNode) {
		addChild(node)
		nodes?.units[uid] = node
	}

	func removeUnit(_ uid: UnitID) {
		nodes?.units[uid]?.removeFromParent()
		nodes?.units[uid] = .none
	}

	private func didSetState(oldValue: GameState) {
		nodes?.cursor.position = state.cursor.point
		camera?.position = state.camera.point
		updateFogIfNeeded(oldValue)
		updateShopIfNeeded(oldValue.shop)
		if state.isCursorTooFar { state.alignCamera() }

		Task {
			for event in state.events { await processEvent(event) }
			if !state.events.isEmpty { state.events = [] }
			if !state.isHuman { state.runAI() }
		}
	}
}

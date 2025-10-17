import SpriteKit
import GameplayKit

final class GameScene: SKScene {
	private(set) var state: GameState = .random()
	{ didSet { didSetState(oldValue: oldValue) } }

	private(set) var menuState: ModalMenu?
	{ didSet { didSetMenu(oldValue: oldValue) } }

	private(set) var nodes: BattlefieldNodes?

	private let hid = HIDController()

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFill

		nodes = BattlefieldNodes(
			cursor: addCursor(),
			map: addMap(state.map),
			menu: addMenu()
		)
		camera = addCamera()
		state.initialize()

		hid.inputStream = { [weak self] input in self?.apply(input) }
	}

	func apply(_ input: Input) {
		if case .none = menuState { state.apply(input) }
		else { menuState?.apply(input) }
	}

	func show(_ menu: ModalMenu?) {
		menuState = menu
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
		if state.isCursorTooFar { state.alignCamera() }

		Task {
			for event in state.events { await processEvent(event) }
			if !state.events.isEmpty { state.events = [] }
			if !state.isHuman { state.runAI() }
		}
	}

	private func didSetMenu(oldValue: ModalMenu?) {
		if let menuState {
			if oldValue == nil {
				nodes?.menu.isHidden = false
			} else if let action = menuState.action {
				if case let .apply(transform) = action { transform(&state) }
				show(.none)
			}
		} else if oldValue != nil {
			nodes?.menu.isHidden = true
			nodes?.menu.removeAllChildren()
		}
	}
}

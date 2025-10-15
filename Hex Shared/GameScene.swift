import SpriteKit
import GameplayKit

final class GameScene: SKScene {
	private(set) var state: State = .random()
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

		hid.inputStream = { [weak self] input in self?.applyInput(input) }
	}

	func applyInput(_ input: Input) {
		if state.events.isEmpty/*, state[state.currentPlayer]?.ai == false*/ {
			state.apply(input)
		}
	}

	func act(on hex: Hex) {
		if state.cursor == hex {
			applyInput(.action(.a))
		} else {
			state.cursor = hex
			applyInput(.action(.a))
		}
	}

	func addUnit(_ uid: UnitID, node: SKNode) {
		addChild(node)
		nodes?.units[uid] = node
	}

	func removeUnit(_ uid: UnitID) {
		nodes?.units[uid]?.removeFromParent()
		nodes?.units[uid] = .none
	}
}

private extension GameScene {

	func didSetState(oldValue: State) {
		nodes?.cursor.position = state.cursor.point
		camera?.position = state.camera.point

		if state.visible != oldValue.visible || state.selectable != oldValue.selectable {
			updateFog()
		}

		Task { await reduceEvents() }
	}

	private func reduceEvents() async {
		for event in state.events { await processEvent(event) }
		if !state.events.isEmpty { state.events = [] }
	}
}

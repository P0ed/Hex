import SpriteKit
import GameplayKit

final class GameScene: SKScene {
	private(set) var state: State = .random()
	{ didSet { didSetState(oldValue: oldValue) } }

	private(set) var cursor: SKNode?
	private(set) var fog: SKTileMapNode?
	private(set) var selection: SKTileMapNode?
	private(set) var grid: SKNode?
	private(set) var units: [UnitID: SKNode] = [:]

	private let hid = HIDController()

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFill

		let map = addMap(state.map)
		fog = map.fog
		selection = map.selection
		grid = map.grid
		camera = addCamera()
		cursor = addCursor()

		state.initialize()

		hid.inputStream = { [weak self] input in self?.applyInput(input) }
	}

	func applyInput(_ input: Input) {
		if state.events.isEmpty/*, state[state.currentPlayer]?.ai == false*/ {
			state.apply(input)
		}
	}

	func addUnit(_ uid: UnitID, node: SKNode) {
		addChild(node)
		units[uid] = node
	}

	func removeUnit(_ uid: UnitID) {
		units[uid]?.removeFromParent()
		units[uid] = .none
	}
}

private extension GameScene {

	func didSetState(oldValue: State) {
		cursor?.position = state.cursor.point
		camera?.position = state.camera.point

		if state.visible != oldValue.visible || state.selectable != oldValue.selectable {
			updateFog()
		}

		if state.events.isEmpty { return }
		Task { await reduceEvents() }
	}

	private func reduceEvents() async {
		for event in state.events { await processEvent(event) }
		state.events = []
	}
}

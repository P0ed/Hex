import SpriteKit
import GameplayKit

final class GameScene: SKScene {
	private(set) var state: State = .random() { didSet { didSetState() } }
	private(set) var cursor: SKNode?
	private(set) var selected: SKNode?
	private(set) var fog: SKNode?
	private(set) var grid: SKNode?
	private(set) var units: [UnitID: SKNode] = [:]
	private let hid = HIDController()

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFill

		let map = addMap(state.map)
		grid = map.grid
		camera = addCamera()
		selected = addSelected()
		cursor = addCursor()

		if let cursor { camera?.constraints = [.distance(.init(upperLimit: 200), to: cursor)] }

		state.events = state.units.map { u in .spawn(u.id) }

		hid.inputStream = { [weak self] input in
			if let self, state.events.isEmpty { applyInput(input) }
		}
	}

	func applyInput(_ input: Input) {
		state.apply(input)
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

	func didSetState() {
		cursor?.position = state.cursor.point
		let selectedHex = state.selectedUnit.flatMap { uid in state[uid]?.position }
		selected?.isHidden = selectedHex == nil
		selected?.position = selectedHex.map { hex in hex.point } ?? .zero

		if state.events.isEmpty { return }
		Task { await reduceEvents() }
	}

	func reduceEvents() async {
		for event in state.events { await processEvent(event) }
		state.events = []
	}

	func addCamera() -> SKCameraNode {
		let camera = SKCameraNode()
		addChild(camera)
		return camera
	}

	func addSelected() -> SKNode {
		let selected = SKShapeNode(hex: .zero, base: .baseSelection, line: .lineSelection)
		selected.zPosition = 2.0
		addChild(selected)
		return selected
	}

	func addCursor() -> SKNode {
		let cursor = SKShapeNode(hex: .zero, base: .baseCursor, line: .lineCursor)
		cursor.zPosition = 3.0
		addChild(cursor)
		return cursor
	}
}

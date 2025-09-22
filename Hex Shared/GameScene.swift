import SpriteKit

final class GameScene: SKScene {
	private var state: State = .initial {
		didSet { didSetState() }
	}

	private var hid: HIDController?
	private var cursor: SKNode?
	private var selected: SKNode?
	private var units: [UnitID: SKNode] = [:]

	func applyInput(_ input: Input) {
		state.apply(input)
	}

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFill

		addCamera()
		addMap()
		addCursor()
		addSelected()

		state.events = state.units.map { u in .spawn(u.id) }
	}

	private func didSetState() {
		cursor?.position = state.cursor.point
		let selectedHex = state.selectedUnit.flatMap { uid in
			state[uid]?.position
		}
		selected?.isHidden = selectedHex == nil
		selected?.position = selectedHex.map { hex in hex.point } ?? .zero

		if state.events.isEmpty { return }
		state.events.forEach(processEvent)
		state.events = []
	}

	private func processEvent(_ event: Event) {
		switch event {
		case let .spawn(uid):
			if let unit = state[uid] {
				let sprite = unit.sprite
				units[uid] = sprite
				addChild(sprite)
			}
		case let .kill(uid):
			units[uid]?.removeFromParent()
		case let .move(uid):
			if let unit = state[uid] {
				units[uid]?.run(.move(to: unit.position.point, duration: 0.2))
			}
		case let .attack(src, dst):
			units[src]?.run(.hit()) { [dst = units[dst]] in dst?.run(.hit()) }
		}
	}

	private func addCamera() {
		let camera = SKCameraNode()
		addChild(camera)
		self.camera = camera
	}

	private func addMap() {
		state.map.cells.forEach { hex in
			let cell = SKShapeNode(hex: hex, size: .hexSize)
			cell.strokeColor = .lineCell
			cell.fillColor = .baseCell
			addChild(cell)
		}
	}

	private func addCursor() {
		let cursor = SKShapeNode(hex: .zero, size: .hexSize)
		cursor.strokeColor = .lineCursor
		cursor.fillColor = .baseCursor
		cursor.zPosition = 2.0
		addChild(cursor)
		self.cursor = cursor

		camera?.constraints = [.distance(.init(upperLimit: 200), to: cursor)]
	}

	private func addSelected() {
		let selected = SKShapeNode(hex: .zero, size: .hexSize)
		selected.strokeColor = .lineSelection
		selected.fillColor = .baseSelection
		selected.zPosition = 1.0
		addChild(selected)
		self.selected = selected
	}
}

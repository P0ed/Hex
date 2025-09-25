import SpriteKit

final class GameScene: SKScene {
	private(set) var state: State = .initial { didSet { didSetState() } }
	private(set) var cursor: SKNode?
	private(set) var selected: SKNode?
	private(set) var units: [UnitID: SKNode] = [:]
	private var hid: HIDController?

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFill

		addCamera()
		addMap()
		addCursor()
		addSelected()

		if let cursor { camera?.constraints = [.distance(.init(upperLimit: 200), to: cursor)] }

		state.events = state.units.map { u in .spawn(u.id) }

		hid = HIDController { [weak self] input in self?.applyInput(input) }
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
		for event in state.events {
			await processEvent(event)
		}
		state.events = []
	}

	func addCamera() {
		let camera = SKCameraNode()
		addChild(camera)
		self.camera = camera
	}

	func addMap() {
		let fieldDef = SKTileDefinition(texture: .init(image: .field), size: .hex)
		let tileGroupRule = SKTileGroupRule(adjacency: .adjacencyAll, tileDefinitions: [fieldDef])
		let tileGroup = SKTileGroup(rules: [tileGroupRule])
		let tileSet = SKTileSet(tileGroups: [tileGroup], tileSetType: .hexagonalFlat)

		let cells = state.map.cells
		let r = state.map.radii

		let tileMap = SKTileMapNode(
			tileSet: tileSet,
			columns: r * 2 + 1,
			rows: r * 2 + 1,
			tileSize: CGSize(width: .hexSize * 2.0, height: .hexSize * sqrt(3.0))
		)

		cells.forEach { hex in
			tileMap.setTileGroup(tileGroup, forColumn: r + hex.col, row: r + hex.row)
		}

		tileMap.position = .init(x: -.hexSize * 1.5, y: .hexSize * 0.31)
		addChild(tileMap)

		cells.forEach { hex in
			let cell = SKShapeNode(hex: hex, base: .baseCell, line: .lineCell)
			cell.zPosition = 1.0
			addChild(cell)
		}
	}

	func addCursor() {
		let cursor = SKShapeNode(hex: .zero, base: .baseCursor, line: .lineCursor)
		cursor.zPosition = 3.0
		addChild(cursor)
		self.cursor = cursor
	}

	func addSelected() {
		let selected = SKShapeNode(hex: .zero, base: .baseSelection, line: .lineSelection)
		selected.zPosition = 2.0
		addChild(selected)
		self.selected = selected
	}
}

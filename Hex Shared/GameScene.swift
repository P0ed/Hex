import SpriteKit
import GameplayKit

final class GameScene: SKScene {
	private(set) var state: State = .initial { didSet { didSetState() } }
	private(set) var cursor: SKNode?
	private(set) var selected: SKNode?
	private(set) var grid: SKNode?
	private(set) var units: [UnitID: SKNode] = [:]
	private let hid = HIDController()

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFill

		addCamera()
		addMap()
		addSelected()
		addCursor()

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
		let cells = state.map.cells
		let r = state.map.radii

		let noise = GKNoiseMap.terrain(radii: r, seed: 0)
		let grid = SKTileMapNode(tiles: .cell, radii: r)
		grid.zPosition = 1.0
		self.grid = grid

		let terrain = SKTileMapNode(tiles: .terrain, radii: r)
		terrain.position = .init(x: -.hexR * 1.5, y: .hexR * 0.31)
		terrain.addChild(grid)
		addChild(terrain)

		cells.forEach { hex in
			let x = r + hex.q
			let y = r + hex.r + (hex.q - hex.q & 1) / 2
			let pos = SIMD2<Int32>(Int32(x), Int32(y))
			let val = noise.value(at: pos)
			terrain.setTileGroup(.group(at: val), forColumn: x, row: y)
			grid.setTileGroup(.cell, forColumn: x, row: y)
		}
	}

	func addSelected() {
		let selected = SKShapeNode(hex: .zero, base: .baseSelection, line: .lineSelection)
		selected.zPosition = 2.0
		addChild(selected)
		self.selected = selected
	}

	func addCursor() {
		let cursor = SKShapeNode(hex: .zero, base: .baseCursor, line: .lineCursor)
		cursor.zPosition = 3.0
		addChild(cursor)
		self.cursor = cursor
	}
}

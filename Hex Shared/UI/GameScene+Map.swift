import SpriteKit

extension GameScene {

	struct MapNodes {
		var fog: SKTileMapNode
		var selection: SKTileMapNode
		var grid: SKTileMapNode
	}

	func addMap(_ map: Map) -> MapNodes {
		let fog = SKTileMapNode(tiles: .cells, radius: map.radius)
		fog.zPosition = 0.1

		let selection = SKTileMapNode(tiles: .cells, radius: map.radius)
		selection.zPosition = 0.2

		let grid = SKTileMapNode(tiles: .cells, radius: map.radius)
		grid.zPosition = 1.0
		grid.isHidden = true

		let terrain = SKTileMapNode(tiles: .terrain, radius: map.radius)
		terrain.position = .init(x: -.hexR * 1.5, y: .hexR * 0.31)
		terrain.addChild(fog)
		terrain.addChild(selection)
		terrain.addChild(grid)
		addChild(terrain)

		map.cells.forEach { hex in
			let (x, y) = map.converting(hex)
			let tileGroup = map[hex].tileGroup
			terrain.setTileGroup(tileGroup, forColumn: x, row: y)
			grid.setTileGroup(.grid, forColumn: x, row: y)
		}

		return MapNodes(
			fog: fog,
			selection: selection,
			grid: grid
		)
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

	func updateFog() {
		state.map.cells.forEach { hex in
			let (x, y) = state.map.converting(hex)
			if let visible = state.visible {
				fog?.setTileGroup(
					visible.contains(hex) ? nil : .fog,
					forColumn: x, row: y
				)
			}
			if let selectable = state.selectable {
				selection?.setTileGroup(
					selectable.contains(hex) ? nil : .fog,
					forColumn: x, row: y
				)
			}
		}
		fog?.isHidden = state.visible == nil
		selection?.isHidden = state.selectable == nil
	}
}

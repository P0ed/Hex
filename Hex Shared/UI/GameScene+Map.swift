import SpriteKit

extension GameScene {

	struct MapNodes {
		var fog: SKTileMapNode
		var selection: SKTileMapNode
		var flags: SKTileMapNode
		var grid: SKTileMapNode
	}

	struct BattlefieldNodes {
		var cursor: SKNode
		var fog: SKTileMapNode
		var selection: SKTileMapNode
		var flags: SKTileMapNode
		var grid: SKNode
		var units: [UnitID: SKNode]

		init(cursor: SKNode, map: MapNodes) {
			self.cursor = cursor
			self.fog = map.fog
			self.selection = map.selection
			self.flags = map.flags
			self.grid = map.grid
			self.units = [:]
		}
	}

	func addMap(_ map: Map) -> MapNodes {
		let fog = SKTileMapNode(tiles: .cells, radius: map.radius)
		fog.zPosition = 0.1

		let selection = SKTileMapNode(tiles: .cells, radius: map.radius)
		selection.zPosition = 0.2

		let flags = SKTileMapNode(tiles: .flags, radius: map.radius)
		flags.zPosition = 0.3

		let grid = SKTileMapNode(tiles: .cells, radius: map.radius)
		grid.zPosition = 1.0
		grid.isHidden = true

		let terrain = SKTileMapNode(tiles: .terrain, radius: map.radius)
		terrain.position = .init(x: -.hexR * 1.5, y: .hexR * 0.31)
		terrain.addChild(fog)
		terrain.addChild(selection)
		terrain.addChild(flags)
		terrain.addChild(grid)
		addChild(terrain)

		map.cells.forEach { hex in
			let (x, y) = map.converting(hex)
			let tileGroup = map[hex].tileGroup
			terrain.setTileGroup(tileGroup, forColumn: x, row: y)
			grid.setTileGroup(.grid, forColumn: x, row: y)

			if let city = map.cities[hex] {
				flags.setTileGroup(
					city.controller == .axis ? .axis : .allies,
					forColumn: x, row: y
				)
			}
		}

		return MapNodes(
			fog: fog,
			selection: selection,
			flags: flags,
			grid: grid
		)
	}

	func addCamera() -> SKCameraNode {
		let camera = SKCameraNode()
		camera.setScale(1.5)
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
			nodes?.fog.setTileGroup(
				state.visible.contains(hex) ? nil : .fog,
				forColumn: x, row: y
			)
			if let selectable = state.selectable {
				nodes?.selection.setTileGroup(
					selectable.contains(hex) ? nil : .fog,
					forColumn: x, row: y
				)
			}
		}
		state.units.forEach { unit in
			nodes?.units[unit.id]?.isHidden = !state.visible.contains(unit.position)
		}
		nodes?.selection.isHidden = state.selectable == nil
	}

	func updateFlags() {
		state.map.cities.forEach { hex, city in
			let (x, y) = state.map.converting(hex)
			nodes?.flags.setTileGroup(
				city.controller == .axis ? .axis : .allies,
				forColumn: x, row: y
			)
		}
	}
}

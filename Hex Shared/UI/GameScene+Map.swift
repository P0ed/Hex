import SpriteKit

extension GameScene {

	struct MapNodes {
		var grid: SKNode
	}

	func addMap(_ map: Map) -> MapNodes {
		let cells = map.cells
		let r = map.radius

		let grid = SKTileMapNode(tiles: .cell, radius: r)
		grid.zPosition = 1.0

		let terrain = SKTileMapNode(tiles: .terrain, radius: r)
		terrain.position = .init(x: -.hexR * 1.5, y: .hexR * 0.31)
		terrain.addChild(grid)
		addChild(terrain)

		cells.forEach { hex in
			let (x, y) = map.converting(hex)
			let tileGroup = map[hex].tileGroup
			terrain.setTileGroup(tileGroup, forColumn: x, row: y)
			grid.setTileGroup(.cell, forColumn: x, row: y)
		}

		return MapNodes(grid: grid)
	}
}

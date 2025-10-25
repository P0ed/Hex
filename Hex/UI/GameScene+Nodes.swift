import SpriteKit

extension GameScene {

	struct Nodes {
		var cursor: SKNode
		var camera: SKCameraNode
		var map: MapNodes
		var menu: SKNode
		var status: SKLabelNode
		var sounds: SoundNodes
		var units: [UnitID: SKNode] = [:]

		var fog: SKTileMapNode { map.fog }
		var flags: SKTileMapNode { map.flags }
		var grid: SKTileMapNode { map.grid }
	}

	struct SoundNodes {
		var boomS: SKAudioNode
		var boomM: SKAudioNode
		var boomL: SKAudioNode
		var mov: SKAudioNode
	}

	struct MapNodes {
		var fog: SKTileMapNode
		var flags: SKTileMapNode
		var grid: SKTileMapNode
	}

	func addNodes() -> Nodes {
		Nodes(
			cursor: addCursor(),
			camera: addCamera(),
			map: addMap(),
			menu: addMenu(),
			status: addStatus(),
			sounds: addSounds()
		)
	}

	private func addSounds() -> SoundNodes {
		let mk = { name in
			let node = SKAudioNode(fileNamed: name)
			node.autoplayLooped = false
			node.isPositional = false
			return node
		}
		let boomS = mk("boom-s")
		let boomM = mk("boom-m")
		let boomL = mk("boom-l")
		let mov = mk("mov")

		[boomS, boomM, boomL, mov].forEach(addChild)

		return SoundNodes(boomS: boomS, boomM: boomM, boomL: boomL, mov: mov)
	}

	private func addMap() -> MapNodes {
		let buildings = SKTileMapNode(tiles: .buildings, radius: state.map.radius)
		buildings.zPosition = 0.1

		let flags = SKTileMapNode(tiles: .flags, radius: state.map.radius)
		flags.zPosition = 0.2

		let grid = SKTileMapNode(tiles: .cells, radius: state.map.radius)
		grid.zPosition = 0.3
		grid.isHidden = true

		let fog = SKTileMapNode(tiles: .cells, radius: state.map.radius)
		fog.zPosition = 0.4

		let terrain = SKTileMapNode(tiles: .terrain, radius: state.map.radius)
		terrain.position = .init(x: -.hexR * 1.5, y: .hexR * 0.31)
		[buildings, flags, grid, fog].forEach(terrain.addChild)
		addChild(terrain)

		state.map.cells.forEach { hex in
			let (x, y) = state.map.converting(hex)
			let tileGroup = state.map[hex].tileGroup
			terrain.setTileGroup(tileGroup, forColumn: x, row: y)
			grid.setTileGroup(.grid, forColumn: x, row: y)

			if let building = state.buildings[hex] {
				buildings.setTileGroup(
					.city,
					forColumn: x, row: y
				)
				flags.setTileGroup(
					building.player == .deu ? .axis : .allies,
					forColumn: x, row: y
				)
			}
		}

		return MapNodes(
			fog: fog,
			flags: flags,
			grid: grid
		)
	}

	private func addCamera() -> SKCameraNode {
		let camera = SKCameraNode()
		addChild(camera)
		self.camera = camera
		return camera
	}

	private func addSelected() -> SKNode {
		let selected = SKShapeNode(hex: .zero, base: .baseSelection, line: .lineSelection)
		selected.zPosition = 2.0
		addChild(selected)
		return selected
	}

	private func addCursor() -> SKNode {
		let cursor = SKShapeNode(hex: .zero, base: .baseCursor, line: .lineCursor)
		cursor.zPosition = 3.0
		addChild(cursor)
		return cursor
	}

	private func addStatus() -> SKLabelNode {
		let label = SKLabelNode(size: .s)
		camera?.addChild(label)
		label.zPosition = 10.0
		label.horizontalAlignmentMode = .left
		label.verticalAlignmentMode = .baseline
		return label
	}

	func update(cursor: Hex, camera: Hex, scale: Double) {
		let cursorPosition = state.cursor.point
		if nodes?.cursor.position != cursorPosition {
			nodes?.cursor.position = cursorPosition
		}
		let cameraPosition = state.camera.point
		if nodes?.camera.position != cameraPosition {
			nodes?.camera.run(.move(to: cameraPosition, duration: 0.15))
		}
		let cameraScale = CGFloat(state.scale)
		if nodes?.camera.xScale != cameraScale {
			nodes?.camera.run(.scale(to: cameraScale, duration: 0.15))
		}
	}

	func updateFogIfNeeded(_ oldValue: GameState) {
		guard state.visible != oldValue.visible || state.selectable != oldValue.selectable
		else { return }

		let fog = state.selectable ?? state.visible
		state.map.cells.forEach { hex in
			let (x, y) = state.map.converting(hex)
			nodes?.fog.setTileGroup(
				fog.contains(hex) ? nil : .fog,
				forColumn: x, row: y
			)
		}
		state.units.forEach { u in
			nodes?.units[u.id]?.isHidden = !state.visible.contains(u.position)
		}
	}

	func updateFlags() {
		state.buildings.forEach { building in
			let (x, y) = state.map.converting(building.position)
			nodes?.flags.setTileGroup(
				building.player == .deu ? .axis : .allies,
				forColumn: x, row: y
			)
		}
	}

	func updateStatus() {
		nodes?.status.text = menuState?.statusText ?? state.statusText
	}
}

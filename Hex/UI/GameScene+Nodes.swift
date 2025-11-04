import SpriteKit

extension GameScene {

	struct Nodes {
		var cursor: SKNode
		var camera: SKCameraNode
		var map: MapNodes
		var menu: SKNode
		var status: SKLabelNode
		var sounds: SoundNodes
		var units: [UID: SKNode] = [:]

		var buildings: SKTileMapNode { map.buildings }
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
		var terrain: SKTileMapNode
		var buildings: SKTileMapNode
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
		let buildings = SKTileMapNode(tiles: .buildings, width: state.map.width, height: state.map.height)
		buildings.zPosition = 0.1

		let flags = SKTileMapNode(tiles: .flags, width: state.map.width, height: state.map.height)
		flags.zPosition = 0.2

		let grid = SKTileMapNode(tiles: .cells, width: state.map.width, height: state.map.height)
		grid.zPosition = 0.3
		grid.isHidden = true

		let fog = SKTileMapNode(tiles: .cells, width: state.map.width, height: state.map.height)
		fog.zPosition = 0.4

		let terrain = SKTileMapNode(tiles: .terrain, width: state.map.width, height: state.map.height)
		terrain.anchorPoint = CGPoint(x: 0.0, y: 0.5)
		terrain.position = CGPoint(x: -CGSize.tile.width * 0.5, y: 0.0)
		[buildings, flags, grid, fog].forEach { n in
			n.anchorPoint = CGPoint(x: 0.0, y: 0.5)
			terrain.addChild(n)
		}
		addChild(terrain)

		state.map.indices.forEach { xy in
			let tileGroup = state.map[xy].tileGroup
			terrain.setTileGroup(tileGroup, at: xy)
			grid.setTileGroup(.grid, at: xy)
		}

		return MapNodes(
			terrain: terrain,
			buildings: buildings,
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

	private func addCursor() -> SKNode {
		let cursor = SKSpriteNode(imageNamed: "Grid")
		cursor.texture?.filteringMode = .nearest
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

	func update(cursor: XY, camera: XY, scale: Double) {
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

	func updateFogIfNeeded() -> Set<XY> {
		let fog = state.selectable ?? state.player.visible
		if self.fog != fog {
			state.map.indices.forEach { xy in
				nodes?.fog.setTileGroup(fog.contains(xy) ? nil : .fog, at: xy)
			}
			state.units.forEach { i, u in
				nodes?.units[i]?.isHidden = !state.player.visible.contains(u.position)
			}
		}
		return fog
	}

	func updateBuildings() {
		state.buildings.forEach { b in
			nodes?.buildings.setTileGroup(b.type.tile, at: b.position)
			nodes?.flags.setTileGroup(b.country.flag, at: b.position)
		}
	}

	func updateUnits() {
		state.units.forEach { i, u in
			nodes?.units[i]?.update(u)
		}
	}

	func updateStatus() {
		nodes?.status.text = menuState?.statusText ?? state.statusText
	}
}

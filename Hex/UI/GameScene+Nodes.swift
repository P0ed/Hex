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

//		var buildings: SKTileMapNode { map.buildings }
//		var fog: SKTileMapNode { map.fog }
//		var flags: SKTileMapNode { map.flags }
	}

	struct SoundNodes {
		var boomS: SKAudioNode
		var boomM: SKAudioNode
		var boomL: SKAudioNode
		var mov: SKAudioNode
	}

	@MainActor
	struct MapNodes {
		var layers: [SKTileMapNode]
		var size: Int
//		var buildings: SKTileMapNode
//		var fog: SKTileMapNode
//		var flags: SKTileMapNode
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
//		let buildings = SKTileMapNode(tiles: .buildings, size: state.map.size)
//		buildings.zPosition = 0.4
//
//		let flags = SKTileMapNode(tiles: .flags, size: state.map.size)
//		flags.zPosition = 0.5
//
//		let fog = SKTileMapNode(tiles: .cells, size: state.map.size)
//		fog.zPosition = 0.7
//		fog.blendMode = .multiplyAlpha

		let layers = (0 ..< state.map.size * 2).map { idx in
			SKTileMapNode(tiles: .terrain, size: state.map.size)
		}
		layers.enumerated().forEach { idx, layer in
			layer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
			layer.position = CGPoint(x: -CGSize.tile.width * 0.5, y: 0.0)
			layer.zPosition = CGFloat(idx)
			addChild(layer)
		}

//		[buildings, flags, fog].forEach { n in
//			n.anchorPoint = CGPoint(x: 0.0, y: 0.5)
//			terrain.addChild(n)
//		}

		let map = MapNodes(
			layers: layers,
			size: state.map.size
		)

		state.map.indices.forEach { xy in
			map.setTileGroup(state.map[xy].tileGroup, at: xy)
		}

		return map
	}

	private func addCamera() -> SKCameraNode {
		let camera = SKCameraNode()
		addChild(camera)
		self.camera = camera
		return camera
	}

	private func addCursor() -> SKNode {
		let node = SKNode()
		node.position = .init(x: -1.0, y: -1.0)

		let sprite = SKSpriteNode(texture: .init(image: .cursor))
		sprite.texture?.filteringMode = .nearest
		sprite.zPosition = 0.1

		node.addChild(sprite)
		addChild(node)

		return node
	}

	private func addStatus() -> SKLabelNode {
		let label = SKLabelNode(size: .s)
		camera?.addChild(label)
		label.zPosition = 66.0
		label.horizontalAlignmentMode = .left
		label.verticalAlignmentMode = .baseline
		return label
	}

	func update(cursor: XY, camera: XY, scale: Double) {
		guard let nodes else { return }

		let cursorPosition = state.map.point(at: state.cursor)
		if nodes.cursor.position != cursorPosition {
			nodes.cursor.position = cursorPosition
			nodes.cursor.zPosition = nodes.map.zPosition(at: state.cursor)
		}
		let cameraPosition = state.camera.point
		if nodes.camera.position != cameraPosition {
			nodes.camera.run(.move(to: cameraPosition, duration: 0.15))
		}
		let cameraScale = CGFloat(state.scale)
		if nodes.camera.xScale != cameraScale {
			nodes.camera.run(.scale(to: cameraScale, duration: 0.15))
		}
	}

	func updateFogIfNeeded() -> Set<XY> {
		let fog = state.selectable ?? state.player.visible
		if self.fog != fog {
			state.map.indices.forEach { xy in
//				nodes?.fog.setTileGroup(fog.contains(xy) ? nil : .fog, at: xy)
			}
			state.units.forEach { i, u in
				nodes?.units[i]?.isHidden = !state.player.visible.contains(u.position)
			}
		}
		return fog
	}

	func updateBuildings() {
		state.buildings.forEach { b in
//			nodes?.buildings.setTileGroup(b.type.tile, at: b.position)
//			nodes?.flags.setTileGroup(b.country.flag, at: b.position)
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

extension GameScene.MapNodes {

	func layer(at xy: XY) -> Int {
		xy.x + size - 1 - xy.y
	}

	func setTileGroup(_ tileGroup: SKTileGroup?, at xy: XY) {
		layers[layer(at: xy)].setTileGroup(tileGroup, at: xy)
	}

	func zPosition(at xy: XY) -> CGFloat {
		CGFloat(layer(at: xy))
	}
}

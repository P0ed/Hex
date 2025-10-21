import SpriteKit

extension GameScene {

	struct Nodes {
		var cursor: SKNode
		var camera: SKCameraNode
		var fog: SKTileMapNode
		var flags: SKTileMapNode
		var grid: SKTileMapNode
		var menu: SKNode
		var status: SKLabelNode
		var units: [UnitID: SKNode]

		init(
			cursor: SKNode,
			camera: SKCameraNode,
			map: MapNodes,
			menu: SKNode,
			status: SKLabelNode
		) {
			self.cursor = cursor
			self.camera = camera
			self.fog = map.fog
			self.flags = map.flags
			self.grid = map.grid
			self.status = status
			self.menu = menu
			self.units = [:]
		}
	}

	struct MapNodes {
		var fog: SKTileMapNode
		var flags: SKTileMapNode
		var grid: SKTileMapNode
	}

	func addMap(_ map: Map) -> MapNodes {
		let flags = SKTileMapNode(tiles: .flags, radius: map.radius)
		flags.zPosition = 0.1

		let grid = SKTileMapNode(tiles: .cells, radius: map.radius)
		grid.zPosition = 0.2
		grid.isHidden = true

		let fog = SKTileMapNode(tiles: .cells, radius: map.radius)
		fog.zPosition = 0.3

		let terrain = SKTileMapNode(tiles: .terrain, radius: map.radius)
		terrain.position = .init(x: -.hexR * 1.5, y: .hexR * 0.31)
		terrain.addChild(flags)
		terrain.addChild(grid)
		terrain.addChild(fog)
		addChild(terrain)

		map.cells.forEach { hex in
			let (x, y) = map.converting(hex)
			let tileGroup = map[hex].tileGroup
			terrain.setTileGroup(tileGroup, forColumn: x, row: y)
			grid.setTileGroup(.grid, forColumn: x, row: y)

			if let city = map.cities[hex] {
				flags.setTileGroup(
					city.controller == .deu ? .axis : .allies,
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

	func addMenu() -> SKNode {
		let menu = SKShapeNode(
			rectOf: Nodes.menuSize,
			cornerRadius: Nodes.outerR
		)
		menu.fillColor = .lightGray
		menu.strokeColor = .gray
		menu.zPosition = 10.0
		menu.isHidden = true
		addChild(menu)
		return menu
	}

	func addCamera() -> SKCameraNode {
		let camera = SKCameraNode()
		addChild(camera)
		self.camera = camera
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

	func addStatus() -> SKLabelNode {
		let label = SKLabelNode()
		camera?.addChild(label)
		label.fontName = "Menlo"
		label.fontSize = 11.0
		label.fontColor = .white
		label.zPosition = 10.0
		label.setScale(0.5)
		label.horizontalAlignmentMode = .left
		label.verticalAlignmentMode = .bottom
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
		state.map.cities.forEach { hex, city in
			let (x, y) = state.map.converting(hex)
			nodes?.flags.setTileGroup(
				city.controller == .deu ? .axis : .allies,
				forColumn: x, row: y
			)
		}
	}

	func updateStatus() {
		nodes?.status.text = menuState?.statusText ?? state.statusText
	}
}

@MainActor
extension GameScene.Nodes {

	static let inset = 8.0 as CGFloat
	static let spacing = 8.0 as CGFloat
	static let outerR = 12.0 as CGFloat
	static let innerR = outerR - inset / 2.0 as CGFloat

	static let itemSize = CGSize(width: 64.0, height: 52.0)
	static let inspectorSize = CGSize(
		width: itemSize.width * 2 + spacing,
		height: itemSize.height * 3 + spacing * 2
	)
	static let menuSize = CGSize(
		width: itemSize.width * 5 + spacing * 4 + inset * 2,
		height: itemSize.height * 3 + spacing * 2 + inset * 2
	)

	func layout(size: CGSize) {
		status.position = CGPoint(
			x: Self.inset - size.width / 2.0,
			y: Self.inset - size.height / 2.0
		)
	}

	func showMenu(_ menuState: MenuState) {
		menu.isHidden = false
		menu.position = camera.position
		addMenuItems(menuState)
		if menuState.inspector { addMenuInspector() }
		updateMenu(menuState)
	}

	func hideMenu() {
		menu.isHidden = true
		menu.removeAllChildren()
	}

	private func addMenuItems(_ menuState: MenuState) {
		menuState.items.enumerated().map { idx, item in
			let frame = SKShapeNode(rectOf: Self.itemSize, cornerRadius: Self.innerR)

			let x = CGFloat(idx % menuState.cols) * (Self.itemSize.width + Self.spacing)
			let y = CGFloat(idx / menuState.cols) * (Self.itemSize.height + Self.spacing)

			frame.position = CGPoint(
				x: Self.inset + Self.itemSize.width / 2.0 - Self.menuSize.width / 2.0 + x,
				y: Self.menuSize.height / 2.0 - Self.inset - Self.itemSize.height / 2.0 - y
			)

			let sprite = SKSpriteNode(imageNamed: item.icon)
			sprite.texture?.filteringMode = .nearest
			frame.addChild(sprite)

			return frame
		}
		.forEach(menu.addChild)
	}

	func addMenuInspector() {
		let frame = SKShapeNode(rectOf: Self.inspectorSize, cornerRadius: Self.innerR)
		frame.fillColor = .gray
		frame.strokeColor = .darkGray
		frame.name = "inspector"
		frame.position = CGPoint(
			x: Self.menuSize.width / 2.0 - Self.inset - Self.inspectorSize.width / 2.0,
			y: Self.menuSize.height / 2.0 - Self.inset - Self.inspectorSize.height / 2.0
		)
		menu.addChild(frame)

		let label = SKLabelNode()
		label.verticalAlignmentMode = .top
		label.horizontalAlignmentMode = .left
		label.position = CGPoint(
			x: Self.inset - Self.inspectorSize.width / 2.0,
			y: Self.inspectorSize.height / 2.0 - Self.inset,
		)
		label.zPosition = 0.1
		label.name = "label"
		label.fontSize = 11.0
		label.fontName = "Menlo"
		label.numberOfLines = 0
		frame.addChild(label)
	}

	func updateMenu(_ menuState: MenuState) {
		menu.children.enumerated().forEach { idx, item in
			if let frame = item as? SKShapeNode, frame.name == nil {
				frame.fillColor = menuState.cursor == idx ? .gray : .darkGray
				frame.strokeColor = menuState.cursor == idx ? .darkGray : .black
			}
			if idx == menuState.cursor, let inspector = menu.menuInspectorLabel {
				inspector.text = menuState.items[idx].description
			}
		}
	}
}

extension SKNode {

	var menuInspectorLabel: SKLabelNode? {
		childNode(withName: "inspector")?.childNode(withName: "label") as? SKLabelNode
	}
}

extension GameState {

	var statusText: String {
		if let selectedUnit, let unit = self[selectedUnit] {
			unit.status
		} else if let city = map.cities[cursor] {
			city.name
		} else {
			"\(map[cursor])"
		}
	}
}

extension MenuState {

	var statusText: String { items[cursor].text }
}

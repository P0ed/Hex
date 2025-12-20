import SpriteKit

struct HQNodes {
	var cursor: SKNode
	var camera: SKCameraNode
	var map: MapNodes
	var units: [UID: SKNode] = [:]
}

extension HQNodes {

	static let map = Map<Terrain>(size: 4, zero: .field)

	init(parent: SKNode, state: borrowing HQState) {
		self = HQNodes(
			cursor: Self.addCursor(parent: parent),
			camera: Self.addCamera(parent: parent),
			map: Self.addMap(parent: parent, state: state),
			units: [:]
		)
	}

	private static func addMap(parent: SKNode, state: borrowing HQState) -> MapNodes {

		let layers = (0 ..< map.size * 2 - 1).map { idx in
			SKTileMapNode(tiles: .terrain, size: map.size)
		}
		layers.enumerated().forEach { idx, layer in
			layer.anchorPoint = CGPoint(x: 0.0, y: 0.5)
			layer.position = CGPoint(x: -CGSize.tile.width * 0.5, y: 0.0)
			layer.zPosition = CGFloat(idx)
			parent.addChild(layer)
		}

		let nodes = MapNodes(
			layers: layers,
			size: map.size
		)

		map.indices.forEach { xy in
			nodes.setTileGroup(map[xy].tileGroup(fog: false), at: xy)
		}

		return nodes
	}

	private static func addCamera(parent: SKNode) -> SKCameraNode {
		let camera = SKCameraNode()
		parent.addChild(camera)
		(parent as? SKScene)?.camera = camera
		return camera
	}

	private static func addCursor(parent: SKNode) -> SKNode {
		let node = SKNode()
		node.position = .init(x: -1.0, y: -1.0)

		let cursor = SKSpriteNode(texture: .init(image: .cursor))
		cursor.texture?.filteringMode = .nearest
		cursor.zPosition = 0.1

		node.addChild(cursor)
		parent.addChild(node)

		return node
	}

	func update(state: borrowing HQState) {
		let cursorPosition = Self.map.point(at: state.cursor)
		if cursor.position != cursorPosition {
			cursor.position = cursorPosition
			cursor.zPosition = map.zPosition(at: state.cursor)
		}
		let cameraPosition = state.camera.point
		if camera.position != cameraPosition {
			camera.run(.move(to: cameraPosition, duration: 0.15))
		}
	}

	func mouse(event: NSEvent) -> Input? { nil }
}

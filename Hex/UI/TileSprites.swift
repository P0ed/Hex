import SpriteKit
import GameplayKit

@MainActor
extension SKTileGroup {

	private static func make(_ image: NSImage) -> SKTileGroup {
		SKTileGroup(
			tileDefinition: SKTileDefinition(
				texture: .init(image: image),
				size: .hex
			)
		)
	}

	static let city = make(.city)
	static let mammut = make(.mammut)
	static let barracks = make(.barracks)
	static let factory = make(.factory)

	static let axis = make(.axisFlag)
	static let allies = make(.alliesFlag)

	static let grid = make(.grid)
	static let fog = make(.fog)

	static let field = make(.field)
	static let forest = make(.forest)
	static let hills = make(.hills)
	static let mountains = make(.mountains)
}

@MainActor
extension Terrain {

	static func terrain(at height: Float, humidity: Float) -> Terrain {
		switch height {
		case 0.0 ..< 0.3: .forest
		case 0.3 ..< 0.6: humidity > 0 ? .forest : .hills
		case 0.6 ..< 0.8: .hills
		case 0.8 ... 1.0: .mountains
		default: .field
		}
	}

	var tileGroup: SKTileGroup {
		switch self {
		case .field: .field
		case .forest: .forest
		case .hills: .hills
		case .mountains: .mountains
		}
	}
}

@MainActor
extension SKTileSet {

	static let cells = SKTileSet(
		tileGroups: [.grid, .fog],
		tileSetType: .hexagonalFlat
	)
	static let terrain = SKTileSet(
		tileGroups: [.field, .forest, .hills, .mountains],
		tileSetType: .hexagonalFlat
	)
	static let buildings = SKTileSet(
		tileGroups: [.city, .barracks, .factory, .mammut],
		tileSetType: .hexagonalFlat
	)
	static let flags = SKTileSet(
		tileGroups: [.axis, .allies],
		tileSetType: .hexagonalFlat
	)
}

@MainActor
extension SKTileMapNode {
	convenience init(tiles: SKTileSet, radius: Int) {
		self.init(
			tileSet: tiles,
			columns: radius * 2 + 1,
			rows: radius * 2 + 1,
			tileSize: .hex
		)
	}
}

@MainActor
extension GKNoiseMap {

	private static func map(radius: Int, source: GKNoiseSource) -> GKNoiseMap {
		GKNoiseMap(
			GKNoise(source),
			size: .one,
			origin: .zero,
			sampleCount: SIMD2<Int32>(Int32(radius) * 2, Int32(radius) * 2),
			seamless: false
		)
	}

	static func height(radius: Int, seed: Int) -> GKNoiseMap {
		.map(radius: radius, source: GKPerlinNoiseSource(
			frequency: 10.0,
			octaveCount: 6,
			persistence: 0.47,
			lacunarity: 0.68,
			seed: Int32(bitPattern: UInt32(seed & Int(UInt32.max)))
		))
	}

	static func humidity(radius: Int, seed: Int) -> GKNoiseMap {
		.map(radius: radius, source: GKVoronoiNoiseSource(
			frequency: 6.8,
			displacement: 1.0,
			distanceEnabled: false,
			seed: Int32(bitPattern: UInt32(seed & Int(UInt32.max)))
		))
	}
}

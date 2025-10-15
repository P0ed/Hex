import SpriteKit
import GameplayKit

@MainActor
extension SKTileGroup {

	private static func make(_ image: NSImage) -> SKTileGroup {
		SKTileGroup(
			tileDefinition: SKTileDefinition(
				texture: .init(image: image),
				size: CGSize(width: 2 * .hexR, height: 2 * .hexR)
			)
		)
	}

	static let axis = make(.axisFlag)
	static let allies = make(.alliesFlag)
	static let grid = make(.grid)
	static let fog = make(.fog)
	static let field = make(.field)
	static let forest = make(.forest)
	static let hills = make(.hills)
	static let mountains = make(.mountains)
	static let city = make(.city)
}

@MainActor
extension Terrain {

	static func terrain(at height: Float) -> Terrain {
		switch (height + 1.0) / 2.0 {
		case 0.0 ..< 0.4: .field
		case 0.4 ..< 0.7: .forest
		case 0.7 ..< 0.9: .hills
		case 0.9 ... 1.0: .mountains
		default: .field
		}
	}

	var tileGroup: SKTileGroup {
		switch self {
		case .field: .field
		case .forest: .forest
		case .hills: .hills
		case .mountains: .mountains
		case .city: .city
		default: .field
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
		tileGroups: [.field, .forest, .hills, .mountains, .city],
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

	static func terrain(radius: Int, seed: Int) -> GKNoiseMap {

		let perlin = GKNoise(GKPerlinNoiseSource(
			frequency: 8.2,
			octaveCount: 6,
			persistence: 0.47,
			lacunarity: 0.68,
			seed: Int32(seed)
		))
//		let ridged = GKNoise(GKRidgedNoiseSource(
//			frequency: 8.2,
//			octaveCount: 5,
//			lacunarity: 0.82,
//			seed: Int32(seed)
//		))
//		let voronoi = GKNoise(GKVoronoiNoiseSource(
//			frequency: 6.8,
//			displacement: 1.0,
//			distanceEnabled: false,
//			seed: Int32(seed)
//		))

		let noiseMap = GKNoiseMap(
			perlin,
			size: .one,
			origin: .zero,
			sampleCount: SIMD2<Int32>(Int32(radius) * 2, Int32(radius) * 2),
			seamless: false
		)

		return noiseMap
	}
}

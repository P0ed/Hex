import SpriteKit
import GameplayKit

@MainActor
extension SKTileGroup {

	private static func make(_ image: NSImage) -> SKTileGroup {
		SKTileGroup(
			tileDefinition: SKTileDefinition(texture: .init(image: image), size: .hex)
		)
	}

	static let grid = make(.grid)
	static let fog = make(.fog)
	static let field = make(.field)
	static let forest = make(.forest)
	static let hills = make(.hills)
	static let mountains = make(.mountains)
	static let swamp = make(.swamp)
}

@MainActor
extension Terrain {

	static func terrain(at height: Float) -> Terrain {
		switch (height + 1.0) / 2.0 {
		case 0.0 ..< 0.1: .swamp
		case 0.1 ..< 0.5: .field
		case 0.5 ..< 0.7: .forest
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
		case .swamp: .swamp
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
		tileGroups: [.field, .forest, .hills, .mountains, .swamp],
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
			tileSize: CGSize(width: .hexR * 2.0, height: .hexR * sqrt(3.0))
		)
	}
}

@MainActor
extension GKNoiseMap {

	static func terrain(radius: Int, seed: Int) -> GKNoiseMap {

		let noiseSource = GKPerlinNoiseSource(
			frequency: 8.2,
			octaveCount: 6,
			persistence: 0.47,
			lacunarity: 0.68,
			seed: Int32(seed)
		)
		let noiseMap = GKNoiseMap(
			GKNoise(noiseSource),
			size: .one,
			origin: .zero,
			sampleCount: SIMD2<Int32>(Int32(radius) * 2 + 1, Int32(radius) * 2 + 1),
			seamless: false
		)

		return noiseMap
	}
}

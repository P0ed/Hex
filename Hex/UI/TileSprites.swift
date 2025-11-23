import SpriteKit
import GameplayKit

@MainActor
extension SKTileGroup {

	private static func make(_ image: NSImage) -> SKTileGroup {
		SKTileGroup(
			tileDefinition: SKTileDefinition(
				texture: .init(image: image),
				size: .tile
			)
		)
	}

	static let city = make(.city)
	static let mammut = make(.mammut)
	static let barracks = make(.barracks)
	static let factory = make(.factory)

	static let ukr = make(.UKR)
	static let usa = make(.USA)
	static let rus = make(.RUS)
	static let lnr = make(.LNR)
	static let dnr = make(.DNR)
	static let irn = make(.IRN)

	static let grid = make(.grid)
	static let fog = make(.fog)

	static let field = make(.field)
	static let forest = make(.forest)
	static let hills = make(.hills)
	static let mountains = make(.mountains)
}

extension Terrain {

	init(height: Float, humidity: Float) {
		self = switch height {
		case 0.0 ..< 0.3: .forest
		case 0.3 ..< 0.6: humidity > 0 ? .forest : .hills
		case 0.6 ..< 0.8: .hills
		case 0.8 ... 1.0: .mountains
		default: .field
		}
	}
}

@MainActor
extension Terrain {

	var tileGroup: SKTileGroup? {
		switch self {
		case .field: .field
		case .forest: .forest
		case .hills: .hills
		case .mountains: .mountains
		case .none: .none
		}
	}
}

@MainActor
extension Country {

	var flag: SKTileGroup {
		switch self {
		case .dnr: .dnr
		case .lnr: .lnr
		case .irn: .irn
		case .isr: .usa
		case .rus: .rus
		case .swe: .ukr
		case .ukr: .ukr
		case .usa: .usa
		}
	}
}

@MainActor
extension SKTileSet {

	static let cells = SKTileSet(
		tileGroups: [.grid, .fog],
		tileSetType: .grid
	)
	static let terrain = SKTileSet(
		tileGroups: [.field, .forest, .hills, .mountains],
		tileSetType: .grid
	)
	static let buildings = SKTileSet(
		tileGroups: [.city, .barracks, .factory, .mammut],
		tileSetType: .grid
	)
	static let flags = SKTileSet(
		tileGroups: [.ukr, .usa, .dnr, .lnr, .rus, .irn],
		tileSetType: .grid
	)
}

@MainActor
extension SKTileMapNode {

	convenience init(tiles: SKTileSet, width: Int, height: Int) {
		self.init(
			tileSet: tiles,
			columns: width,
			rows: height,
			tileSize: .tile
		)
	}

	func setTileGroup(_ tileGroup: SKTileGroup?, at xy: XY) {
		setTileGroup(tileGroup, forColumn: xy.x, row: xy.y)
	}
}

extension GKNoiseMap {

	private static func map(size: SIMD2<Int32>, source: GKNoiseSource) -> GKNoiseMap {
		GKNoiseMap(
			GKNoise(source),
			size: .one,
			origin: .zero,
			sampleCount: size,
			seamless: false
		)
	}

	static func height(size: SIMD2<Int32>, seed: Int) -> GKNoiseMap {
		.map(size: size, source: GKPerlinNoiseSource(
			frequency: 10.0,
			octaveCount: 6,
			persistence: 0.47,
			lacunarity: 0.68,
			seed: Int32(bitPattern: UInt32(seed & Int(UInt32.max)))
		))
	}

	static func humidity(size: SIMD2<Int32>, seed: Int) -> GKNoiseMap {
		.map(size: size, source: GKVoronoiNoiseSource(
			frequency: 6.8,
			displacement: 1.0,
			distanceEnabled: false,
			seed: Int32(bitPattern: UInt32(seed & Int(UInt32.max)))
		))
	}
}

import SpriteKit
import GameplayKit

@MainActor
extension SKTileGroup {

	private static func make(_ image: NSImage) -> SKTileGroup {
		SKTileGroup(
			tileDefinition: SKTileDefinition(
				texture: .init(image: image),
				size: image.size
			)
		)
	}

	static let ukr = make(.UKR)
	static let usa = make(.USA)
	static let rus = make(.RUS)
	static let lnr = make(.LNR)
	static let dnr = make(.DNR)
	static let irn = make(.IRN)

	static let city = make(.city)
	static let field = make(.field)
	static let forest = make(.forest)
	static let forestHill = make(.forestHill)
	static let hill = make(.hill)
	static let mountain = make(.mountain)

	static let cityFog = make(.cityFog)
	static let fieldFog = make(.fieldFog)
	static let forestFog = make(.forestFog)
	static let forestHillFog = make(.forestHillFog)
	static let hillFog = make(.hillFog)
	static let mountainFog = make(.mountainFog)
}

@MainActor
extension Terrain {

	func tileGroup(fog: Bool) -> SKTileGroup? {
		if fog {
			switch self {
			case .field: .field
			case .forest: .forest
			case .hill: .hill
			case .forestHill: .forestHill
			case .mountain: .mountain
			case .city: .city
			case .none: .none
			}
		} else {
			switch self {
			case .field: .fieldFog
			case .forest: .forestFog
			case .hill: .hillFog
			case .forestHill: .forestHillFog
			case .mountain: .mountainFog
			case .city: .cityFog
			case .none: .none
			}
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

	static let terrain = SKTileSet(
		tileGroups: [
			.city, .field, .forest, .hill, .forestHill, .mountain,
			.cityFog, .fieldFog, .forestFog, .hillFog, .forestHillFog, .mountainFog
		],
		tileSetType: .isometric
	)
}

@MainActor
extension SKTileMapNode {

	convenience init(tiles: SKTileSet, size: Int) {
		self.init(
			tileSet: tiles,
			columns: size,
			rows: size,
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

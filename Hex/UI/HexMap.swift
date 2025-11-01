import SpriteKit

@MainActor
extension SKShader {

	static let hexMap: SKShader = {
//		SKShader(fileNamed: "TileMap.fsh")
		SKShader(source: try! String(
			contentsOf: #bundle.url(forResource: "TileMap", withExtension: "fsh")!,
			encoding: .utf8
		))
	}()
}

@MainActor
final class HexMapNode: SKSpriteNode {
	private let hexWidth: CGFloat = 64
	private let hexHeight: CGFloat = 56
	private let horizontalSpacing: CGFloat = 50
	private let verticalSpacing: CGFloat = 56

	required init?(coder aDecoder: NSCoder) { fatalError() }

	init(map: borrowing Map, terrainAtlas: SKTexture) {
		let spriteWidth = CGFloat(map.width - 1) * horizontalSpacing + hexWidth
		let spriteHeight = CGFloat(map.height) * hexHeight + hexHeight * 0.5

		super.init(texture: terrainAtlas, color: .black, size: CGSize(width: spriteWidth, height: spriteHeight))

		let terrainDataTexture = SKTexture.render(map)
		terrainDataTexture.filteringMode = .nearest
		terrainAtlas.filteringMode = .nearest

		let shader = SKShader.hexMap
		shader.uniforms = [
			SKUniform(name: "u_terrain_data", texture: terrainDataTexture),
			SKUniform(name: "u_cols", float: Float(map.width)),
			SKUniform(name: "u_rows", float: Float(map.height)),
			SKUniform(name: "u_hex_width", float: Float(hexWidth)),
			SKUniform(name: "u_hex_height", float: Float(hexHeight)),
			SKUniform(name: "u_horizontal_spacing", float: Float(horizontalSpacing)),
			SKUniform(name: "u_vertical_spacing", float: Float(verticalSpacing)),
			SKUniform(name: "u_sprite_width", float: Float(spriteWidth)),
			SKUniform(name: "u_sprite_height", float: Float(spriteHeight))
		]
		self.shader = shader
	}
}

extension SKTexture {

	static func render(_ map: borrowing Map) -> SKTexture {

		guard let provider = CGDataProvider(data: map.terrainData as CFData) else {
			fatalError("Failed to create data provider")
		}

		guard let image = CGImage(
			width: map.width,
			height: map.height,
			bitsPerComponent: 8,
			bitsPerPixel: 8,
			bytesPerRow: map.width,
			space: CGColorSpaceCreateDeviceGray(),
			bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue),
			provider: provider,
			decode: nil,
			shouldInterpolate: false,
			intent: .defaultIntent
		) else {
			fatalError("Failed to create CGImage")
		}

		return SKTexture(cgImage: image)
	}
}

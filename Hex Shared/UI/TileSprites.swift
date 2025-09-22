import SpriteKit

extension SKTextureAtlas {
	static var tiles: Self { .init(named: "Tiles") }
}

extension SKTexture {
	static var field: SKTexture {
		SKTextureAtlas.tiles.textureNamed("field.png")
	}
}

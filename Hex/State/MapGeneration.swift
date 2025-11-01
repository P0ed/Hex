import GameplayKit

extension Map {

	init(width: Int, height: Int, seed: Int) {
		self = Map(width: width, height: height)

		let size = SIMD2<Int32>(Int32(width), Int32(height))
		let height = GKNoiseMap.height(size: size, seed: seed)
		let humidity = GKNoiseMap.humidity(size: size, seed: seed + 1)

		self.indices.forEach { xy in
			let pos = SIMD2<Int32>(Int32(xy.x), Int32(xy.y))
			self[xy] = Terrain(
				height: height.value(at: pos),
				humidity: humidity.value(at: pos)
			)
		}
	}
}

import GameplayKit

extension Map {

	init(size: Int, seed: Int) {
		self = Map(size: size)

		let size = SIMD2<Int32>(Int32(size), Int32(size))
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

extension Terrain {

	init(height: Float, humidity: Float) {
		self = switch height {
		case -0.5 ..< 0.3: humidity > 0.5 ? .forest : .field
		case 0.3 ..< 0.7: humidity > 0.5 ? .forestHill : .hill
		case 0.7 ..< 0.85: .hill
		case 0.85 ... 1.0: .mountain
		default: .field
		}
	}
}

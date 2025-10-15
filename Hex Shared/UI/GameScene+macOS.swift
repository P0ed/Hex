import SpriteKit

#if os(OSX)
extension GameScene {

	override func keyDown(with event: NSEvent) {
		switch event.specialKey {
		case .leftArrow: applyInput(.direction(.left))
		case .rightArrow: applyInput(.direction(.right))
		case .downArrow: applyInput(.direction(.down))
		case .upArrow: applyInput(.direction(.up))
		default: break
		}
		switch event.characters {
		case "q": applyInput(.target(.prev))
		case "w": applyInput(.target(.next))
		case "e": applyInput(.menu)
		case "a": applyInput(.action(.a))
		case "s": applyInput(.action(.b))
		case "d": applyInput(.action(.c))
		case "f": applyInput(.action(.d))
		case "z": camera?.run(
			.scale(to: (camera?.xScale ?? 1.0) > 3.0 ? 2.0 : 4.0, duration: 0.15)
		)
		case "x": nodes?.grid.isHidden.toggle()
		default: break
		}
	}

	override func mouseDown(with event: NSEvent) {
		guard let grid = nodes?.grid as? SKTileMapNode else { return }
		let location = event.location(in: grid)
		let hex = state.map.converting(
			col: grid.tileColumnIndex(fromPosition: location),
			row: grid.tileRowIndex(fromPosition: location)
		)
		act(on: hex)
	}
}
#endif

import SpriteKit

#if os(OSX)
extension GameScene {

	override func keyDown(with event: NSEvent) {
		switch event.specialKey {
		case .leftArrow: apply(.direction(.left))
		case .rightArrow: apply(.direction(.right))
		case .downArrow: apply(.direction(.down))
		case .upArrow: apply(.direction(.up))
		default: break
		}
		switch event.characters {
		case "q": apply(.target(.prev))
		case "w": apply(.target(.next))
		case "e": apply(.menu)
		case "a": apply(.action(.a))
		case "s": apply(.action(.b))
		case "d": apply(.action(.c))
		case "f": apply(.action(.d))
		case "z": camera?.run(
			.scale(to: (camera?.xScale ?? 1.0) > 3.0 ? 2.0 : 4.0, duration: 0.15)
		)
		case "x": nodes?.grid.isHidden.toggle()
		default: break
		}
	}

	override func mouseDown(with event: NSEvent) {
		guard let grid = nodes?.grid else { return }
		let location = event.location(in: grid)
		apply(.tap(
			state.map.converting(
				col: grid.tileColumnIndex(fromPosition: location),
				row: grid.tileRowIndex(fromPosition: location)
			)
		))
	}
}
#endif

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
		case "z": camera?.run(.scale(to: (camera?.xScale ?? 1.0) > 4.0 ? 1.5 : 8.0, duration: 0.33))
		case "x": nodes?.grid.isHidden.toggle()
		default: break
		}
	}
}
#endif

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
		case "r": applyInput(.target(.next))
		case "w": applyInput(.menu(.no))
		case "e": applyInput(.menu(.yes))
		case "a": applyInput(.action(.a))
		case "s": applyInput(.action(.b))
		case "d": applyInput(.action(.c))
		case "f": applyInput(.action(.d))
		case "z": camera?.run(.scale(to: (camera?.xScale ?? 1.0) > 2.0 ? 1.0 : 4.0, duration: 0.33))
		case "x": camera?.run(.scale(to: 12.0, duration: 0.33))
		case "c": grid?.isHidden.toggle()
		default: break
		}
	}

	override func keyUp(with event: NSEvent) {
		switch event.characters {
		case "x": camera?.run(.scale(to: 1.0, duration: 0.33))
		default: break
		}
	}
}
#endif

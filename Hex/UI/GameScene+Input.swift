import SpriteKit

extension GameScene {

	override func keyDown(with event: NSEvent) {
		switch event.keyCode {
		case 36, 49: apply(.action(.a))
		case 51, 53: apply(.action(.b))
		default: break
		}
		switch event.specialKey {
		case .tab: apply(.menu)
		case .leftArrow: apply(.direction(.left))
		case .rightArrow: apply(.direction(.right))
		case .downArrow: apply(.direction(.down))
		case .upArrow: apply(.direction(.up))
		default: break
		}
		switch event.characters {
		case "[": apply(.target(.prev))
		case "]": apply(.target(.next))
		case "a": apply(.action(.a))
		case "s": apply(.action(.b))
		case "d": apply(.action(.c))
		case "f": apply(.action(.d))
		case "z": apply(.scale(1.0))
		case "x": apply(.scale(2.0))
		case "c": apply(.scale(4.0))
		case "v": nodes?.grid.isHidden.toggle()
		case "q" where event.modifierFlags.contains(.command): exit(0)
		default: break
		}
	}

	override func mouseDown(with event: NSEvent) {
		guard let nodes else { return }
		if menuState == nil {
			let location = event.location(in: nodes.grid)
			apply(.hex(
				state.map.converting(
					col: nodes.grid.tileColumnIndex(fromPosition: location),
					row: nodes.grid.tileRowIndex(fromPosition: location)
				)
			))
		} else {
			guard self.nodes(at: event.location(in: self))
				.contains(where: { n in n == nodes.menu })
			else { return apply(.action(.b)) }

			nodes.menu.nodes(at: event.location(in: nodes.menu))
				.compactMap { n in n as? SKShapeNode }.first
				.flatMap { n in n.name == nil ? n : nil }
				.flatMap(nodes.menu.children.firstIndex)
				.map { idx in apply(.index(idx)) }
		}
	}
}

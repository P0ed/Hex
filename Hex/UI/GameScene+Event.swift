import SpriteKit

extension GameScene {

	func processEvent(_ event: Event) async {
		switch event {
		case let .spawn(uid): processSpawn(uid: uid)
		case let .update(uid): processUpdate(uid: uid)
		case let .kill(uid): processKill(uid: uid)
		case let .move(uid): await processMove(uid: uid)
		case let .attack(src, dst): await processAttack(src: src, dst: dst)
		case .reflag: updateFlags()
		case .shop: processShop()
		case .menu: processMenu()
		case .gameOver: processGameOver()
		}
	}
}

private extension GameScene {

	func processSpawn(uid: UnitID) {
		guard let unit = state[uid] else { return }
		let sprite = unit.sprite
		sprite.isHidden = !state.visible.contains(unit.position)
		addUnit(uid, node: sprite)
	}

	func processUpdate(uid: UnitID) {
		guard let unit = state[uid], let sprite = nodes?.units[uid]
		else { return processSpawn(uid: uid) }

		sprite.update(unit)
		sprite.isHidden = !state.visible.contains(unit.position)
	}

	func processKill(uid: UnitID) {
		removeUnit(uid)
	}

	func processMove(uid: UnitID) async {
		guard let unit = state[uid] else { return }
		nodes?.sounds.mov.play()
		await nodes?.units[uid]?.run(.move(to: unit.position.point, duration: 0.2))
	}

	func processAttack(src: UnitID, dst: UnitID) async {
		nodes?.sounds.boomS.play()
		await nodes?.units[src]?.run(.hit())
		nodes?.sounds.boomM.play()
		await nodes?.units[dst]?.run(.hit())

		if let srcUnit = state[src] {
			nodes?.units[src]?.update(srcUnit)
		}
		if let dstUnit = state[dst] {
			nodes?.units[dst]?.update(dstUnit)
		}
	}

	func processShop() {
		guard let city = state.map.cities[state.cursor],
			  city.controller == state.player,
			  state.units[state.cursor] == nil
		else { return }

		show(MenuState(
			layout: .inspector,
			items: state.unitTemplates.map { template in
				MenuItem(
					icon: template.imageName,
					text: "\(template.stats.unitType)",
					description: template.description + " / \(state.prestige)",
					action: { [hex = state.cursor] state in
						state.buy(template, at: hex)
					}
				)
			}
		))
	}

	func processMenu() {
		if state.selectedUnit != nil {
			show(MenuState(layout: .compact, items: state.unitMenuActions))
		} else {
			show(MenuState(
				layout: .compact,
				items: [
					.init(icon: "End", text: "End turn", action: { state in
						state.endTurn()
					}),
					.init(
						icon: "Restart", text: "Restart",
						action: { [weak self] _ in self?.restartGame() }
					)
				]
			))
		}
	}

	func processGameOver() {
		show(MenuState(
			layout: .compact,
			items: [.init(
				icon: "Restart", text: "Restart",
				action: { [weak self] _ in self?.restartGame() }
			)]
		))
	}

	private func restartGame() {
		view?.presentScene(
			GameScene(size: size),
			transition: .moveIn(with: .up, duration: 0.47)
		)
	}
}

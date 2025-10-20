import SpriteKit

extension GameScene {

	func processEvent(_ event: Event) async {
		switch event {
		case let .spawn(uid): processSpawn(uid: uid)
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

	func processKill(uid: UnitID) {
		removeUnit(uid)
	}

	func processMove(uid: UnitID) async {
		guard let unit = state[uid] else { return }
		await nodes?.units[uid]?.run(.move(to: unit.position.point, duration: 0.2))
	}

	func processAttack(src: UnitID, dst: UnitID) async {
		await nodes?.units[src]?.run(.hit())
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
			items: state.unitTemplates.map { template in
				MenuItem(
					icon: template.imageName,
					text: "\(template.stats.unitType)",
					description: template.description + " / \(state.prestige)",
					action: { [hex = state.cursor] state in
						state.buy(template, at: hex)
					}
				)
			},
			inspector: true
		))
	}

	func processMenu() {
		show(MenuState(
			items: [.init(
				icon: "Restart", text: "Restart",
				action: { [weak self] _ in self?.restartGame() }
			)],
			inspector: false
		))
	}

	func processGameOver() {
		show(MenuState(
			items: [.init(
				icon: "Restart", text: "Restart",
				action: { [weak self] _ in self?.restartGame() }
			)],
			inspector: false
		))
	}

	private func restartGame() {
		view?.presentScene(
			GameScene(size: size),
			transition: .moveIn(with: .up, duration: 0.47)
		)
	}
}

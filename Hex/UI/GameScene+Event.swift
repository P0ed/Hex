import SpriteKit

extension GameScene {

	func processEvent(_ event: Event) async {
		switch event {
		case let .spawn(uid): processSpawn(uid: uid)
		case let .update(uid): processUpdate(uid: uid)
		case let .move(uid): await processMove(uid: uid)
		case let .attack(src, dst): await processAttack(src: src, dst: dst)
		case .reflag: updateFlags()
		case .shop: processShop()
		case .build: processBuild()
		case .menu: processMenu()
		case .gameOver: processGameOver()
		}
	}
}

private extension GameScene {

	func processSpawn(uid: UnitID) {
		let unit = state.units[state.units[uid]]
		let sprite = unit.sprite
		sprite.isHidden = !state.visible.contains(unit.position)
		addUnit(uid, node: sprite)
	}

	func processUpdate(uid: UnitID) {
		guard let sprite = nodes?.units[uid] else { return }

		if let unit = state.units.first(where: { u in u.id == uid }) {
			sprite.update(unit)
			sprite.isHidden = !state.visible.contains(unit.position)
		} else {
			removeUnit(uid)
		}
	}

	func processMove(uid: UnitID) async {
		let unit = state.units[state.units[uid]]
		nodes?.sounds.mov.play()
		await nodes?.units[uid]?.run(.move(to: unit.position.point, duration: 0.2))
	}

	func processAttack(src: UnitID, dst: UnitID) async {
		nodes?.sounds.boomS.play()
		await nodes?.units[src]?.run(.hit())
		nodes?.sounds.boomM.play()
		await nodes?.units[dst]?.run(.hit())

		processUpdate(uid: src)
		processUpdate(uid: dst)
	}

	func processShop() {
		guard let building = state.buildings[state.cursor],
			  building.player == state.player,
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

	func processBuild() {
		guard let engineerRef = state.units[state.cursor],
			  state.units[engineerRef].stats.unitType == .engineer
		else { return }

		show(MenuState(
			layout: .inspector,
			items: state.buildingTemplates.map { template in
				MenuItem(
					icon: template.type.imageName,
					text: template.type.imageName,
					description: "0" + " / \(state.prestige)",
					action: { [hex = state.cursor] state in
						state.build(template, at: hex)
					}
				)
			}
		))
	}

	func processMenu() {
		guard case .none = menuState else { return show(.none) }

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

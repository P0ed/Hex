import SpriteKit

extension GameScene {

	func processEvent(_ event: Event) async {
		switch event {
		case let .spawn(uid): processSpawn(uid: uid)
		case let .move(uid, distance): await processMove(uid: uid, distance: distance)
		case let .attack(src, dst, unit): await processAttack(src: src, dst: dst, unit: unit)
		case .reflag: updateBuildings()
		case .nextDay: updateUnits()
		case .shop: processShop()
		case .build: processBuild()
		case .menu: processMenu()
		case .gameOver: processGameOver()
		}
	}
}

private extension GameScene {

	func processSpawn(uid: UID) {
		let sprite = state.units[uid].sprite
		sprite.isHidden = !state.player.visible.contains(state.units[uid].position)
		addUnit(uid, node: sprite)
	}

	func processMove(uid: UID, distance: Int) async {
		nodes?.sounds.mov.play()
		await nodes?.units[uid]?.run(.move(
			to: state.units[uid].position.point,
			duration: CGFloat(distance) * 0.1
		))
	}

	func processAttack(src: UID, dst: UID, unit: Unit) async {
		nodes?.units[src]?.showSight(for: 1.0)
		await run(.wait(forDuration: 0.47))
		nodes?.units[dst]?.showSight(for: 1.0 - 0.47)
		await run(.wait(forDuration: 0.47))

		if unit.alive {
			nodes?.sounds.boomM.play()
			nodes?.units[dst]?.update(unit)
		} else {
			nodes?.sounds.boomL.play()
			removeUnit(dst)
		}
	}

	func processShop() {
		guard let building = state.buildings[state.cursor],
			  building.country == state.country,
			  state.units[state.cursor] == nil
		else { return }

		show(MenuState(
			layout: .inspector,
			items: state.unitTemplates.map { template in
				MenuItem(
					icon: template.imageName,
					text: "\(template.stats.unitType)",
					description: template.description + " / \(state.player.prestige)",
					action: { [hex = state.cursor] state in
						state.buy(template, at: hex)
					}
				)
			}
		))
	}

	func processBuild() {
		guard let (i, u) = state.units[state.cursor], u.stats.unitType == .engineer
		else { return }

		show(MenuState(
			layout: .inspector,
			items: state.buildingTemplates.map { template in
				MenuItem(
					icon: template.type.imageName,
					text: template.type.imageName,
					description: "\(template.description)" + " / \(state.player.prestige)",
					action: { state in
						state.build(template, by: i)
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

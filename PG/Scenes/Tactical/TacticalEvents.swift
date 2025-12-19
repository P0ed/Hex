import SpriteKit

extension TacticalScene {

	func process(events: [TacticalEvent]) async {
		for e in events { await process(e) }
	}
}

private extension TacticalScene {

	func process(_ event: TacticalEvent) async {
		switch event {
		case let .spawn(uid): processSpawn(uid: uid)
		case let .move(uid, distance): await processMove(uid: uid, distance: distance)
		case let .attack(src, dst, unit): await processAttack(src: src, dst: dst, unit: unit)
		case .nextDay: nodes?.updateUnits(state)
		case .shop: processShop()
		case .build: processBuild()
		case .menu: processMenu()
		case .gameOver: processGameOver()
		case .none: break
		}
	}

	func processSpawn(uid: UID) {
		guard let nodes else { return }

		let sprite = state.units[uid].sprite
		let xy = state.units[uid].position
		sprite.position = state.map.point(at: xy)
		sprite.zPosition = nodes.map.zPosition(at: xy)
		sprite.isHidden = !state.player.visible[xy]
		addUnit(uid, node: sprite)
	}

	func processMove(uid: UID, distance: Int) async {
		guard let nodes, let unit = nodes.units[uid] else { return }

		let xy = state.units[uid].position
		let z = nodes.map.zPosition(at: xy)
		unit.zPosition = max(unit.zPosition, z)
		nodes.sounds.mov.play()
		await unit.run(.move(
			to: state.map.point(at: xy),
			duration: CGFloat(distance) * 0.047
		))
		unit.zPosition = z
	}

	func processAttack(src: UID, dst: UID, unit: Unit) async {
		nodes?.units[src]?.showSight(for: 0.68)
		await run(.wait(forDuration: 0.33))
		nodes?.units[dst]?.showSight(for: 0.68 - 0.33)
		await run(.wait(forDuration: 0.33))

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
					action: { [xy = state.cursor] state in
						state.buy(template, at: xy)
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
			Scene(mode: .tactical, state: .random()),
			transition: .moveIn(with: .up, duration: 0.47)
		)
	}
}

extension GameScene {

	func processEvent(_ event: Event) async {
		switch event {
		case let .spawn(uid): processSpawn(uid: uid)
		case let .kill(uid): processKill(uid: uid)
		case let .move(uid): await processMove(uid: uid)
		case let .attack(src, dst): await processAttack(src: src, dst: dst)
		}
	}
}

private extension GameScene {

	func processSpawn(uid: UnitID) {
		guard let unit = state[uid] else { return }
		let sprite = unit.sprite
		addUnit(uid, node: sprite)
	}

	func processKill(uid: UnitID) {
		removeUnit(uid)
	}

	func processMove(uid: UnitID) async {
		guard let unit = state[uid] else { return }
		await units[uid]?.run(.move(to: unit.position.point, duration: 0.2))
	}

	func processAttack(src: UnitID, dst: UnitID) async {
		await units[src]?.run(.hit())
		await units[dst]?.run(.hit())

		if let srcUnit = state[src] {
			units[src]?.update(srcUnit)
		}
		if let dstUnit = state[dst] {
			units[dst]?.update(dstUnit)
		}
	}
}

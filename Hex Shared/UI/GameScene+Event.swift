extension GameScene {

	func processEvent(_ event: Event) {
		switch event {
		case let .spawn(uid): processSpawn(uid: uid)
		case let .kill(uid): processKill(uid: uid)
		case let .move(uid): processMove(uid: uid)
		case let .attack(src, dst): processAttack(src: src, dst: dst)
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

	func processMove(uid: UnitID) {
		guard let unit = state[uid] else { return }
		units[uid]?.run(.move(to: unit.position.point, duration: 0.2))
	}

	func processAttack(src: UnitID, dst: UnitID) {
		units[src]?.run(.hit()) { [weak self] in
			self?.units[dst]?.run(.hit()) {
				if let srcUnit = self?.state[src] {
					self?.units[src]?.update(srcUnit)
				}
				if let dstUnit = self?.state[dst] {
					self?.units[dst]?.update(dstUnit)
				}
			}
		}
	}
}

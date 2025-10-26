extension GameState {

	mutating func runAI() {
		guard let target = enemyBuildings.first?.position else { return }

		if let nextAttack {
			attack(src: units[nextAttack.0], dst: units[nextAttack.1])
		} else if let nextMove = nextMove(target: target) {
			move(unit: nextMove.0, to: nextMove.1)
		} else {
			endTurn()
		}
	}

	private var nextAttack: (UnitID, UnitID)? {
		playerUnits.compactMap { u in
			targets(unit: u).first.map { t in (u.id, t.id) }
		}
		.first { _ in true }
	}

	private func nextMove(target: Hex) -> (UnitID, Hex)? {
		playerUnits.compactMap { u in
			moves(for: u)
				.min(by: { ha, hb in
					target.distance(to: ha) < target.distance(to: hb)
				})
				.map { hx in (u.id, hx) }
		}
		.first { _ in true }
	}
}

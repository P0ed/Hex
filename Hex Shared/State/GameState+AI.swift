extension GameState {

	mutating func runAI() {

		if let nextAttackMove {
			attack(src: nextAttackMove.0, dst: nextAttackMove.1)
		} else {
			endTurn()
		}
	}

	private var nextAttackMove: (UnitID, UnitID)? {
		playerUnits.reduce(nil) { r, u in
			if let r { return r }
			if u.canFire, let t = targets(unit: u.id).first { return (u.id, t.id) }
			return nil
		}
	}
}

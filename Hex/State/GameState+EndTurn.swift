extension GameState {

	var day: Int { Int(turn) / players.count + 1 }

	private var aliveTeams: Set<Team> {
		Set(players.compactMap { p in p.alive ? p.country.team : nil })
	}

	mutating func endTurn() {
		captureCities()

		guard nextTurn() else { return events.append(.gameOver) }

		resetUI()
	}

	private mutating func nextTurn() -> Bool {
		for _ in 0..<players.count {
			turn += 1
			if playerIndex == 0 { startNextDay() }
			if player.alive { return aliveTeams.count > 1 }
		}
		return false
	}

	private mutating func startNextDay() {
		players = players.mapInPlace(endTurn)
		units = units.mapInPlace(endTurn)
		events.append(.nextDay)
	}

	private func income(for player: Player) -> UInt16 {
		buildings.reduce(into: 0) { r, b in
			r += b.country == player.country ? b.income : 0
		}
	}

	private mutating func resetUI() {
		selectUnit(.none)

		cursor = units.firstMap { u in u.country == country ? u.position : nil }
		?? buildings.firstMap { b in b.country == country ? b.position : nil }
		?? .zero
		camera = cursor
	}

	private func endTurn(for player: inout Player) {
		player.visible = vision(for: player.country)
		player.prestige.increment(by: income(for: player))
	}

	private func endTurn(for unit: inout Unit) {
		let ns = neighbors(at: unit.position)

		let noEnemy = !ns.contains { n in
			units[n].country.team != unit.country.team
		}
		let hasSupport = ns.contains { n in
			units[n].country.team == unit.country.team
			&& units[n].stats.unitType == .supply
		}
		let hasEngi = ns.contains { n in
			units[n].country.team == unit.country.team
			&& units[n].stats.unitType == .engineer
		}

		unit.stats.ent.increment(
			by: (unit.untouched ? 1 : 0) + (hasEngi ? 1 : 0),
			cap: 7
		)
		unit.stats.ammo.increment(
			by: (unit.untouched ? 2 : 0) + (noEnemy ? 2 : 0) + (hasSupport ? 2 : 0),
			cap: 0xF
		)
		let dhp = unit.stats.hp.increment(
			by: ((unit.untouched ? 4 : 0) + (hasSupport ? 4 : 0)) / (noEnemy ? 1 : 3),
			cap: 0xF
		)
		let dxp = unit.stats.hp / (unit.stats.hp - dhp)
		unit.stats.exp /= dxp

		unit.stats.mp = 1
		unit.stats.ap = 1
	}

	func neighbors(at position: Hex) -> [Ref<Unit>] {
		position.neighbors.compactMap { hx in units[hx] }
	}

	private mutating func captureCities() {
		let reflag = units.reduce(into: false) { reflag, u in

			let idx = buildings.firstIndex { b in b.position == u.position }

			if let idx, buildings[idx].country.team != u.country.team {
				buildings[idx].country = u.country
				reflag = true
			}
		}
		if reflag {
			events.append(.reflag)
			eliminatePlayers()
		}
	}

	private mutating func eliminatePlayers() {
		players = players.mapInPlace { player in
			player.alive = !buildings.contains { building in
				building.type == .city && building.country == player.country
			}
		}
	}
}

extension UInt16 {

	@discardableResult
	mutating func increment(by amount: UInt16, cap: UInt16 = .max) -> UInt16 {
		let old = self
		self = UInt16(Swift.min(UInt32(cap), UInt32(self + amount)))
		return self - old
	}

	@discardableResult
	mutating func decrement(by amount: UInt16 = 1) -> UInt16 {
		let old = self
		self -= self < amount ? self : amount
		return old - self
	}
}

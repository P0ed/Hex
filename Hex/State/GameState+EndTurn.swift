extension GameState {

	mutating func endTurn() {
		guard let idx = players.firstIndex(where: { p in p.id == player })
		else { return }

		players[idx].prestige += income
		captureCities()

		let nextIdx = (idx + 1) % players.count
		player = players[nextIdx].id
		turn = nextIdx == 0 ? turn + 1 : turn
		selectUnit(.none)

		if nextIdx == 0 {
			players = players.mapInPlace { p in p.visible = vision(for: p.id) }
			units = units.mapInPlace { u in u.nextTurn() }
		}
	}

	private mutating func captureCities() {
		let reflag = units.reduce(into: false) { reflag, u in

			let idx = buildings.firstIndex { b in b.position == u.position }

			if let idx, buildings[idx].player.team != u.player.team {
				buildings[idx].player = u.player
				reflag = true
			}
		}
		if reflag {
			events.append(.reflag)
			eliminatePlayers()
		}
	}

	private mutating func eliminatePlayers() {
		players.removeAll { player in
			!buildings.contains { building in
				building.type == .city && building.player == player.id
			}
		}
		if Set(players.map(\.id.team)).count == 1 {
			events.append(.gameOver)
		}
	}
}

extension GameState {

	mutating func endTurn() {
		players[playerIndex].prestige += income
		captureCities()

		repeat { turn += 1 } while !player.alive

		selectUnit(.none)

		cursor = units.firstMap { u in u.country == country ? u.position : nil }
		?? buildings.firstMap { b in b.country == country ? b.position : nil }
		?? .zero
		camera = cursor

		if playerIndex == 0 {
			players = players.mapInPlace { p in p.visible = vision(for: p.country) }
			units = units.mapInPlace { u in u.nextTurn() }
		}
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
		let aliveTeams = Set(players.compactMap { p in
			p.alive ? p.country.team : nil
		})
		if aliveTeams.count == 1 { events.append(.gameOver) }
	}
}

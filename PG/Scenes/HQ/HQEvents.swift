import SpriteKit

enum HQEvent {
	case move(UID, XY)
	case spawn(UID)
	case scenario(Scenario)
	case none
}

extension HQEvent: DeadOrAlive {

	var alive: Bool { if case .none = self { false } else { true } }
}

struct Scenario {
	var mapSize: Int = 16
	var seed: Int = 0
}

extension HQScene {

	func process(events: [Event]) async {
		for event in events { await process(event) }
	}

	private func process(_ event: Event) async {
		switch event {
		case .move(let uid, let xy): processMove(uid: uid, xy: xy)
		case .spawn(let uid): processSpawn(uid: uid)
		case .scenario(let scenario): processScenario(scenario)
		case .none: break
		}
	}

	private func processMove(uid: UID, xy: XY) {
		nodes?.units[uid]?.position = xy.point
		nodes?.units[uid]?.zPosition = nodes?.map.zPosition(at: xy) ?? 0.0
	}

	func processSpawn(uid: UID) {
		guard let nodes else { return }

		let sprite = state.units[uid].hqSprite
		let xy = state.units[uid].position
		sprite.position = HQNodes.map.point(at: xy)
		sprite.zPosition = nodes.map.zPosition(at: xy)
		addUnit(uid, node: sprite)
	}

	private func processScenario(_ scenario: Scenario) {

	}
}

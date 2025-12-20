import SpriteKit

enum HQEvent {
	case move(XY, XY)
	case scenario(Scenario)
	case none
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
		case .move(let src, let dst): processMove(src: src, dst: dst)
		case .scenario(let scenario): processScenario(scenario)
		case .none: break
		}
	}

	private func processMove(src: XY, dst: XY) {

	}

	private func processScenario(_ scenario: Scenario) {

	}
}

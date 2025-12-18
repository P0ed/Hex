import SpriteKit

struct SceneMode<State: ~Copyable, Event, Nodes> {
	var make: (SKNode, borrowing State) -> Nodes
	var inputable: (borrowing State) -> Bool
	var input: (inout State, Input) -> Void
	var update: (borrowing State, Nodes) -> Void
	var reducible: (borrowing State) -> Bool
	var reduce: (inout State, Nodes) -> [Event]
	var process: ([Event], Nodes) async -> Void
	var status: (borrowing State) -> String
	var layout: (CGSize, Nodes) -> Void = ø
}

extension SceneMode<TacticalState, TacticalEvent, TacticalNodes> {

	static var tactical: Self {
		.init(
			make: TacticalNodes.init,
			inputable: { state in state.canHandleInput },
			input: { state, input in state.apply(input) },
			update: { state, nodes in nodes.update(state: state) },
			reducible: reducible,
			reduce: reduce,
			process: process,
			status: { state in state.statusText }
		)
	}

	private static func reducible(state: borrowing State) -> Bool {
		state.isCursorTooFar || !state.events.isEmpty || state.player.ai
	}

	private static func reduce(state: inout State, nodes: Nodes) -> [Event] {
//		fog = updateFogIfNeeded()

		if state.isCursorTooFar {
			state.alignCamera()
			return []
		}

		let events = state.events.map { _, e in e }
//			for event in events { await processEvent(event) }
		if !events.isEmpty {
			state.events.erase()
			return events
		}
		if state.player.ai {
			state.runAI()
		}
		return []
	}

	private static func process(events: [Event], nodes: Nodes) async {

	}
}

struct IO<A: ~Copyable> {

}

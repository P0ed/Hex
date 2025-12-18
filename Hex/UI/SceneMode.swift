import SpriteKit

struct SceneMode<State: ~Copyable, Event, Nodes> {
	var make: (SKNode, borrowing State) -> Nodes
	var inputable: (borrowing State) -> Bool
	var input: (inout State, Input) -> Void
	var update: (borrowing State, Nodes) -> Void
	var reducible: (borrowing State) -> Bool
	var reduce: (inout State) -> [Event]
	var process: (Scene<State, Event, Nodes>, [Event]) async -> Void
	var status: (borrowing State) -> String
	var mouse: (Nodes, NSEvent) -> Input?
	var layout: (CGSize, Nodes) -> Void = ø
}

typealias TacticalMode = SceneMode<TacticalState, TacticalEvent, TacticalNodes>

typealias TacticalScene = Scene<TacticalState, TacticalEvent, TacticalNodes>

extension TacticalMode {

	static var tactical: Self {
		.init(
			make: TacticalNodes.init,
			inputable: { state in state.inputable },
			input: { state, input in state.apply(input) },
			update: { state, nodes in nodes.update(state: state) },
			reducible: { state in state.reducible },
			reduce: { state in state.reduce() },
			process: { scene, events in await scene.process(events: events) },
			status: { state in state.statusText },
			mouse: { nodes, event in nodes.mouse(event: event) }
		)
	}
}

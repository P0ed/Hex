typealias HQMode = SceneMode<HQState, Never, HQNodes>
typealias HQScene = Scene<HQState, Never, HQNodes>

extension HQMode {

	static var hq: Self {
		.init(
			make: HQNodes.init,
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

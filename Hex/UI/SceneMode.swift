import SpriteKit

struct SceneMode<State: ~Copyable & SceneState, Nodes> {
	var make: (SKNode, borrowing State) -> Nodes
	var layout: (CGSize, Nodes) -> Void = ø
}

protocol SceneState: ~Copyable {
	associatedtype Event: DeadOrAlive

	var events: Speicher<128, Event> { get }
	var canHandleInput: Bool { get }
	var statusText: String { get }

	mutating func apply(_ input: Input)
}

extension SceneMode where State == TacticalState, Nodes == TacticalNodes {

	static var tactical: Self {
		.init(make: TacticalNodes.init)
	}
}

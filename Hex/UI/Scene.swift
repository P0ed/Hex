import SpriteKit
import GameplayKit

final class Scene<State: ~Copyable, Event, Nodes>: SKScene {
	private let mode: SceneMode<State, Event, Nodes>
	private(set) var menuState: MenuState? { didSet { didSetMenu() } }
	private(set) var state: State { didSet { didSetState() } }

	private(set) var baseNodes: BaseNodes?
	private(set) var nodes: Nodes?
	private(set) var fog: SetXY?

	private let hid = HIDController()

	init(mode: SceneMode<State, Event, Nodes>, state: consuming State, size: CGSize = .scene) {
		self.state = state
		self.mode = mode
		super.init(size: size)
	}

	required init?(coder aDecoder: NSCoder) { fatalError() }

	override func becomeFirstResponder() -> Bool {
		super.becomeFirstResponder()
		return true
	}

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFit

		baseNodes = makeBaseNodes()

		let nodes = mode.make(self, state)
		mode.layout(size, nodes)
		self.nodes = nodes
		mode.update(state, nodes)

//		state.events = .init(head: state.units.map { i, _ in .spawn(i) }, tail: .gameOver)


		hid.inputStream = { [weak self] input in self?.apply(input) }
	}

	override func didChangeSize(_ oldSize: CGSize) {
		if let nodes { mode.layout(size, nodes) }
	}

	override func keyDown(with event: NSEvent) {
		processKeyEvent(event)
	}

	override func mouseDown(with event: NSEvent) {
		
	}

	func apply(_ input: Input) {
		if case .some = menuState {
			menuState?.apply(input)
		} else if mode.inputable(state) {
			mode.input(&state, input)
		}
	}

	func show(_ menu: MenuState?) {
		menuState = menu.flatMap { m in m.items.isEmpty ? .none : m }
	}

	private func didSetState() {
		guard let nodes else { return }

//		fog = updateFogIfNeeded()
		updateStatus()
		mode.update(state, nodes)

		if mode.reducible(state) {
			let events = mode.reduce(&state, nodes)
			if !events.isEmpty {
				Task { await mode.process(events, nodes) }
			}
		}
	}

	private func didSetMenu() {
//		if let action = menuState?.action {
//			if let menuState, case let .apply(idx) = action {
//				menuState.items[idx].action(&state)
//			}
//			return menuState = .none
//		} else if (menuState == nil) != (nodes?.menu.isHidden == true) {
//			if let menuState { nodes?.showMenu(menuState) }
//			else { nodes?.hideMenu() }
//		} else if let menuState {
//			nodes?.updateMenu(menuState)
//		}
//		updateStatus()
	}

	private func updateStatus() {
		baseNodes?.status.text = menuState?.statusText ?? mode.status(state)
	}
}

extension Scene<TacticalState, TacticalEvent, TacticalNodes> {

	func addUnit(_ uid: UID, node: SKNode) {
		addChild(node)
		nodes?.units[uid] = node
	}

	func removeUnit(_ uid: UID) {
		nodes?.units[uid]?.removeFromParent()
		nodes?.units[uid] = .none
	}
}

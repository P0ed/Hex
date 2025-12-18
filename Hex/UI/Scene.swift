import SpriteKit
import GameplayKit

final class Scene<State: ~Copyable & SceneState, Nodes>: SKScene {
	private let mode: SceneMode<State, Nodes>
	private(set) var state: State { didSet { didSetState() } }
	private(set) var menuState: MenuState? { didSet { didSetMenu() } }

	private(set) var nodes: Nodes?
	private(set) var menuNode: SKNode?
	private(set) var status: SKLabelNode?
	private(set) var fog: SetXY?

	private let hid = HIDController()

	init(mode: SceneMode<State, Nodes>, state: consuming State, size: CGSize = .scene) {
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

		let nodes = mode.make(self, state)
		mode.layout(size, nodes)
		self.nodes = nodes

		menuNode = addMenu()
		status = addStatus()

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
		} else if state.canHandleInput {
			state.apply(input)
		}
	}

	func show(_ menu: MenuState?) {
		menuState = menu.flatMap { m in m.items.isEmpty ? .none : m }
	}

	private func didSetState() {
//		nodes?.update(cursor: state., camera: <#T##XY#>, scale: <#T##Double#>)
//		update(cursor: state.cursor, camera: state.camera, scale: state.scale)
//		fog = updateFogIfNeeded()
//		updateStatus()
//		if state.isCursorTooFar { return state.alignCamera() }
//
//		Task {
//			let events = state.events.map { _, e in e }
//			for event in events { await processEvent(event) }
//			if !events.isEmpty { return state.events.erase() }
//			if state.player.ai { return state.runAI() }
//		}
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
}

extension Scene where State == TacticalState, Nodes == TacticalNodes {

	func addUnit(_ uid: UID, node: SKNode) {
		addChild(node)
		nodes?.units[uid] = node
	}

	func removeUnit(_ uid: UID) {
		nodes?.units[uid]?.removeFromParent()
		nodes?.units[uid] = .none
	}
}

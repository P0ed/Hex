import SpriteKit
import GameplayKit

final class Scene<State: ~Copyable, Event, Nodes>: SKScene {
	let mode: SceneMode<State, Event, Nodes>
	private(set) var menuState: MenuState<State>? { didSet { didSetMenu() } }
	private(set) var state: State { didSet { didSetState() } }

	private(set) var baseNodes: BaseNodes?
	private(set) var nodes: Nodes?
	private var processing = false

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

		let nodes = mode.make(self, state)
		mode.layout(size, nodes)
		self.nodes = nodes

		baseNodes = makeBaseNodes()
		baseNodes?.layout(size: size)

		hid.inputStream = { [weak self] input in self?.apply(input) }

		didSetState()
	}

	override func didChangeSize(_ oldSize: CGSize) {
		if let nodes { mode.layout(size, nodes) }
		baseNodes?.layout(size: size)
	}

	override func keyDown(with event: NSEvent) {
		processKeyEvent(event)
	}

	override func mouseDown(with event: NSEvent) {
		processMouseEvent(event)
	}

	func apply(_ input: Input) {
		if case .some = menuState {
			menuState?.apply(input)
		} else if mode.inputable(state) {
			mode.input(&state, input)
		}
	}

	func show(_ menu: MenuState<State>?) {
		menuState = menu.flatMap { m in m.items.isEmpty ? .none : m }
	}

	private func didSetState() {
		guard !processing, let nodes else { return }

		updateStatus()
		mode.update(state, nodes)

		if mode.reducible(state) {
			processing = true
			let events = mode.reduce(&state)
			if !events.isEmpty {
				Task {
					await mode.process(self, events)
					processing = false
					if mode.reducible(state) { didSetState() }
				}
			} else {
				processing = false
				if mode.reducible(state) { didSetState() }
			}
		}
	}

	private func didSetMenu() {
		if let action = menuState?.action {
			if let menuState, case let .apply(idx) = action {
				menuState.items[idx].action(&state)
			}
			return menuState = .none
		} else if (menuState == nil) != (baseNodes?.menu.isHidden == true) {
			if let menuState { baseNodes?.showMenu(menuState) }
			else { baseNodes?.hideMenu() }
		} else if let menuState {
			baseNodes?.updateMenu(menuState)
		}
		updateStatus()
	}

	private func updateStatus() {
		baseNodes?.status.text = menuState?.statusText ?? mode.status(state)
	}
}

extension TacticalScene {

	func addUnit(_ uid: UID, node: SKNode) {
		addChild(node)
		nodes?.units[uid] = node
	}

	func removeUnit(_ uid: UID) {
		nodes?.units[uid]?.removeFromParent()
		nodes?.units[uid] = .none
	}
}

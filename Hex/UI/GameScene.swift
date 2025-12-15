import SpriteKit
import GameplayKit

final class GameScene: SKScene {
	private(set) var state: GameState = .random() { didSet { didSetState() } }
	private(set) var menuState: MenuState? { didSet { didSetMenu() } }

	private(set) var nodes: Nodes?
	private(set) var fog: Set<XY>?

	private let hid = HIDController()

	override func becomeFirstResponder() -> Bool {
		super.becomeFirstResponder()
		return true
	}

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFit

		nodes = addNodes()
		nodes?.layout(size: size)
		updateBuildings()

		state.events = state.units.map { i, _ in .spawn(i) }

		hid.inputStream = { [weak self] input in self?.apply(input) }
	}

	override func didChangeSize(_ oldSize: CGSize) {
		nodes?.layout(size: size)
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

	func addUnit(_ uid: UID, node: SKNode) {
		addChild(node)
		nodes?.units[uid] = node
	}

	func removeUnit(_ uid: UID) {
		nodes?.units[uid]?.removeFromParent()
		nodes?.units[uid] = .none
	}

	private func didSetState() {
		update(cursor: state.cursor, camera: state.camera, scale: state.scale)
		fog = updateFogIfNeeded()
		updateStatus()
		if state.isCursorTooFar { return state.alignCamera() }

		Task {
			for event in state.events { await processEvent(event) }
			if !state.events.isEmpty { return state.events = [] }
			if state.player.ai { return state.runAI() }
		}
	}

	private func didSetMenu() {
		if let action = menuState?.action {
			if let menuState, case let .apply(idx) = action {
				menuState.items[idx].action(&state)
			}
			return menuState = .none
		} else if (menuState == nil) != (nodes?.menu.isHidden == true) {
			if let menuState { nodes?.showMenu(menuState) }
			else { nodes?.hideMenu() }
		} else if let menuState {
			nodes?.updateMenu(menuState)
		}
		updateStatus()
	}
}

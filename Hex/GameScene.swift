import SpriteKit
import GameplayKit

final class GameScene: SKScene {
	private(set) var state: GameState = .random()
	{ didSet { didSetState(oldValue: oldValue) } }

	private(set) var menuState: MenuState?
	{ didSet { didSetMenu(oldValue: oldValue) } }

	private(set) var nodes: Nodes?

	private let hid = HIDController()

	override func becomeFirstResponder() -> Bool {
		super.becomeFirstResponder()
		return true
	}

	override func sceneDidLoad() {
		backgroundColor = .black
		scaleMode = .aspectFit

		nodes = addNodes()
		state.initialize()
		nodes?.layout(size: size)

		hid.inputStream = { [weak self] input in self?.apply(input) }
	}

	override func didChangeSize(_ oldSize: CGSize) {
		nodes?.layout(size: size)
	}

	func apply(_ input: Input) {
		if case .none = menuState { state.apply(input) }
		else { menuState?.apply(input) }
	}

	func show(_ menu: MenuState?) {
		menuState = menu.flatMap { m in m.items.isEmpty ? .none : m }
	}

	func addUnit(_ uid: UnitID, node: SKNode) {
		addChild(node)
		nodes?.units[uid] = node
	}

	func removeUnit(_ uid: UnitID) {
		nodes?.units[uid]?.removeFromParent()
		nodes?.units[uid] = .none
	}

	private func didSetState(oldValue: GameState) {
		update(cursor: state.cursor, camera: state.camera, scale: state.scale)
		updateFogIfNeeded(oldValue)
		updateStatus()
		if state.isCursorTooFar { return state.alignCamera() }

//		let sn = SKAudioNode(fileNamed: "boom-s.wav")
//		sn.autoplayLooped = false
//		addChild(sn)
//		sn.run(.sequence([
//			.play(),
//			.wait(forDuration: 2.0),
//			.removeFromParent()
//		]))

		Task {
			for event in state.events { await processEvent(event) }
			if !state.events.isEmpty { return state.events = [] }
			if !state.isHuman { return state.runAI() }
		}
	}

	private func didSetMenu(oldValue: MenuState?) {
		if let action = menuState?.action {
			if case let .apply(transform) = action { transform(&state) }
			return menuState = .none
		} else if (menuState == nil) != (oldValue == nil) {
			if let menuState { nodes?.showMenu(menuState) }
			else { nodes?.hideMenu() }
		} else if let menuState {
			nodes?.updateMenu(menuState)
		}
		updateStatus()
	}
}

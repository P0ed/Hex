import GameController

final class HIDController {
	private var lifetime: Any?

	var inputStream: (Input) -> Void = { _ in }

	init() {
		lifetime = NotificationCenter.default.addObserver(
			forName: .GCControllerDidBecomeCurrent,
			object: nil,
			queue: .main,
			using: { notification in
				guard let gamepad = (notification.object as? GCController)?.extendedGamepad else { return }

				gamepad.dpad.left.pressedChangedHandler = { _, _, pressed in }
				gamepad.dpad.right.pressedChangedHandler = { _, _, pressed in }
				gamepad.dpad.down.pressedChangedHandler = { _, _, pressed in }
				gamepad.dpad.up.pressedChangedHandler = { _, _, pressed in }
				gamepad.leftShoulder.pressedChangedHandler = { _, _, pressed in }
				gamepad.rightShoulder.pressedChangedHandler = { _, _, pressed in }
				gamepad.buttonA.pressedChangedHandler = { _, _, pressed in }
				gamepad.buttonB.pressedChangedHandler = { _, _, pressed in }
				gamepad.buttonX.pressedChangedHandler = { _, _, pressed in }
				gamepad.buttonY.pressedChangedHandler = { _, _, pressed in }
				gamepad.buttonOptions?.pressedChangedHandler = { _, _, pressed in }
				gamepad.buttonMenu.pressedChangedHandler = { _, _, pressed in }
			}
		)
	}
}

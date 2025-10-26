import AppKit
import SpriteKit

private let window = NSWindow(
	contentRect: NSRect(origin: .zero, size: .window),
	styleMask: [.titled, .closable, .resizable, .miniaturizable],
	backing: .buffered,
	defer: false
)
window.title = "Hex General"
window.center()
window.makeKeyAndOrderFront(nil)

private let willClose = NotificationCenter.default.addObserver(
	forName: NSWindow.willCloseNotification,
	object: window,
	queue: .main,
	using: { _ in exit(0) }
)

private let view = SKView(frame: window.contentLayoutRect)
view.autoresizingMask = [.width, .height]
view.presentScene(GameScene(size: .scene))
window.contentView?.addSubview(view)
window.makeFirstResponder(view)

NSApplication.shared.run()

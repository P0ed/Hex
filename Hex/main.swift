import AppKit
import SpriteKit

let window = NSWindow(
	contentRect: NSRect(origin: .zero, size: .window),
	styleMask: [.titled, .fullSizeContentView, .closable, .resizable, .miniaturizable],
	backing: .buffered,
	defer: false
)
window.titlebarAppearsTransparent = true
window.center()
window.makeKeyAndOrderFront(nil)

let view = SKView(frame: window.contentLayoutRect)
view.ignoresSiblingOrder = true
view.autoresizingMask = [.width, .height]
window.contentView = view
window.makeFirstResponder(view)

let willClose = NotificationCenter.default.addObserver(
	forName: NSWindow.willCloseNotification,
	object: window,
	queue: .main,
	using: { _ in exit(0) }
)

view.presentScene(GameScene(state: .random(), size: .scene))

NSApplication.shared.run()

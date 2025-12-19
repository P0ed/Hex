import AppKit
import SpriteKit

private let window = NSWindow(
	contentRect: NSRect(origin: .zero, size: .window),
	styleMask: [.titled, .fullSizeContentView, .closable, .resizable, .miniaturizable],
	backing: .buffered,
	defer: false
)
window.titlebarAppearsTransparent = true
window.center()
window.makeKeyAndOrderFront(nil)

private let view = SKView(frame: window.contentLayoutRect)
view.ignoresSiblingOrder = true
view.autoresizingMask = [.width, .height]
window.contentView = view
window.makeFirstResponder(view)

private let willClose = NotificationCenter.default.addObserver(
	forName: NSWindow.willCloseNotification,
	object: window,
	queue: .main,
	using: { _ in exit(0) }
)

view.presentScene(Scene(mode: .tactical, state: .random()))

NSApplication.shared.run()

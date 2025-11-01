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

UserDefaults.standard.set(
	nil,
//	["debugDrawStats_SKContextType": true] as [String: Any],
	forKey: "SKDefaults"
)

private let view = SKView(frame: window.contentLayoutRect)
view.autoresizingMask = [.width, .height]
window.contentView = view
window.makeFirstResponder(view)

view.presentScene(GameScene(size: .scene))

private let willClose = NotificationCenter.default.addObserver(
	forName: NSWindow.willCloseNotification,
	object: window,
	queue: .main,
	using: { _ in exit(0) }
)

NSApplication.shared.run()

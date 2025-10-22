import Cocoa
import SpriteKit

private let window = NSWindow(
	contentRect: NSRect(origin: .zero, size: CGSize(width: 640.0, height: 400.0)),
	styleMask: [.titled, .closable, .resizable, .miniaturizable],
	backing: .buffered,
	defer: false
)
window.title = "Hex General"
window.center()
window.makeKeyAndOrderFront(nil)

private let view = SKView(frame: window.contentLayoutRect)
view.autoresizingMask = [.width, .height]
view.presentScene(GameScene(size: view.frame.size))
window.contentView?.addSubview(view)
window.makeFirstResponder(view)

NSApplication.shared.run()

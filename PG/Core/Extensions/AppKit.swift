import AppKit

let app = NSApplication.shared

extension NSWindow {

	static func make(_ content: (NSWindow) -> NSView) -> NSWindow {
		let window = NSWindow(
			contentRect: NSRect(origin: .zero, size: .window),
			styleMask: [.titled, .fullSizeContentView, .closable, .resizable, .miniaturizable],
			backing: .buffered,
			defer: false
		)
		window.contentView = content(window)
		window.titlebarAppearsTransparent = true
		window.center()
		window.makeKeyAndOrderFront(nil)
		window.makeFirstResponder(window.contentView)

		return window
	}
}

extension NotificationCenter {

	func willClose(window: NSWindow, _ body: @escaping () -> Void) -> any NSObjectProtocol {
		addObserver(
			forName: NSWindow.willCloseNotification,
			object: window,
			queue: .main,
			using: { _ in body() }
		)
	}
}

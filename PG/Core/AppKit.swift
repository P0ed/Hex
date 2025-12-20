import AppKit

extension NSWindow {

	static func make(_ content: (NSWindow) -> NSView) -> NSWindow {
		let window = NSWindow(
			contentRect: NSRect(origin: .zero, size: .window),
			styleMask: [.titled, .fullSizeContentView, .closable, .resizable, .miniaturizable],
			backing: .buffered,
			defer: false
		)
		window.titlebarAppearsTransparent = true
		let view = content(window)
		window.contentView = view

		window.center()
		window.makeKeyAndOrderFront(nil)
		window.makeFirstResponder(view)

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

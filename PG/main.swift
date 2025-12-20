import AppKit
import SpriteKit

private let window: NSWindow = .make { window in
	let view = SKView(frame: window.contentLayoutRect)
	view.autoresizingMask = [.width, .height]
	view.ignoresSiblingOrder = true

	view.presentScene(Scene(mode: .tactical, state: .random()))

	return view
}

private let eternity = NotificationCenter.default
	.willClose(window: window) { exit(0) }

NSApplication.shared.run()

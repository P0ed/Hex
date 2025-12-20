import SpriteKit

let core = Core()
core.new()
core.store(tactical: .random())

private let window: NSWindow = .make { window in
	let view = SKView(frame: window.contentLayoutRect)
	view.autoresizingMask = [.width, .height]
	view.ignoresSiblingOrder = true
	view.presentScene(core.makeScene())
	return view
}

private let eternity = NotificationCenter.default
	.willClose(window: window) { exit(0) }

app.run()

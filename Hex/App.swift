import SwiftUI
import SpriteKit

@main
struct HexApp: App {
	@FocusState var focused: Bool

    var body: some Scene {
		Window("Hex", id: "Hex") {
			SpriteView(scene: GameScene(size: CGSize(width: 640, height: 400)))
				.focused($focused)
				.onAppear { focused = true }
				.frame(minWidth: 640, minHeight: 400)
				.ignoresSafeArea()
		}
    }
}

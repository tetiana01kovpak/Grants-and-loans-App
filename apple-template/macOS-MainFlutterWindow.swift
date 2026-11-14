import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
    private let grantBridge = GrantCalendarBridge()
    override func awakeFromNib() {
        let controller = FlutterViewController()
        let windowFrame = self.frame
        self.contentViewController = controller
        self.setFrame(windowFrame, display: true)
        RegisterGeneratedPlugins(registry: controller)
        grantBridge.register(messenger: controller.engine.binaryMessenger)
        super.awakeFromNib()
    }
}

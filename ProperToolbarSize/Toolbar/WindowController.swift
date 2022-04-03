import Cocoa

class WindowController: NSWindowController, NSToolbarDelegate {
    @IBOutlet weak var toolbar: NSToolbar!
    override func windowDidLoad() {
        super.windowDidLoad()
    }
    @IBAction func customAction1(_ sender: NSButton) {
        toolbar.selectedItemIdentifier = toolbar.items[2].itemIdentifier;
    }
    @IBAction func customAction2(_ sender: Any) {
    }
}



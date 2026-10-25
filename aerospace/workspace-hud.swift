import AppKit
import Darwin

private final class WorkspaceHUDDelegate: NSObject, NSApplicationDelegate {
    private let workspace: String
    private let appKitScreenID: Int?
    private var panel: NSPanel?

    init(workspace: String, appKitScreenID: Int?) {
        self.workspace = workspace
        self.appKitScreenID = appKitScreenID
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        guard let screen = targetScreen() else {
            NSApp.terminate(nil)
            return
        }

        let label = NSTextField(labelWithString: workspace.uppercased())
        label.alignment = .center
        label.font = .monospacedSystemFont(ofSize: 42, weight: .semibold)
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false

        let panelHeight: CGFloat = 72
        let panelWidth = max(80, ceil(label.intrinsicContentSize.width) + 44)
        let visibleFrame = screen.visibleFrame
        let panelFrame = NSRect(
            x: visibleFrame.minX + 18,
            y: visibleFrame.maxY - panelHeight - 18,
            width: panelWidth,
            height: panelHeight
        )

        let contentView = NSView(frame: NSRect(origin: .zero, size: panelFrame.size))
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor(calibratedWhite: 0.08, alpha: 0.88).cgColor
        contentView.layer?.cornerRadius = 15
        contentView.layer?.masksToBounds = true
        contentView.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
        ])

        let panel = NSPanel(
            contentRect: panelFrame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = contentView
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.hidesOnDeactivate = false
        panel.ignoresMouseEvents = true
        panel.isReleasedWhenClosed = false
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]
        panel.animationBehavior = .none
        panel.alphaValue = 0

        self.panel = panel
        panel.orderFrontRegardless()

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.10
            panel.animator().alphaValue = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
            NSAnimationContext.runAnimationGroup(
                { context in
                    context.duration = 0.18
                    panel.animator().alphaValue = 0
                },
                completionHandler: {
                    NSApp.terminate(nil)
                }
            )
        }
    }

    private func targetScreen() -> NSScreen? {
        let screens = NSScreen.screens

        if let appKitScreenID,
           screens.indices.contains(appKitScreenID - 1) {
            return screens[appKitScreenID - 1]
        }

        return NSScreen.main ?? screens.first
    }
}

let arguments = Array(CommandLine.arguments.dropFirst())
if arguments.isEmpty || arguments[0].isEmpty {
    exit(0)
}

let workspace = arguments[0]
let appKitScreenID = arguments.dropFirst().first.flatMap { Int($0) }
let app = NSApplication.shared
private let delegate = WorkspaceHUDDelegate(workspace: workspace, appKitScreenID: appKitScreenID)

_ = app.setActivationPolicy(.accessory)
app.delegate = delegate
app.run()

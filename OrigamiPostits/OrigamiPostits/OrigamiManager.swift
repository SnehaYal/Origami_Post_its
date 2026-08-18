import AppKit
import SwiftUI
import Combine
import QuartzCore

// MARK: - Origami manager
//
// Spawns folded origamis onto the desktop and keeps their windows alive.

final class OrigamiManager {
    static let shared = OrigamiManager()
    private var controllers: [UUID: OrigamiPanelController] = [:]
    private init() {}

    func spawn(type: OrigamiType, color: NoteColor, at noteFrame: NSRect) {
        let origami = Origami(type: type, colorName: color)
        let controller = OrigamiPanelController(origami: origami, noteFrame: noteFrame) { [weak self] id in
            self?.controllers[id] = nil
        }
        controllers[origami.id] = controller
        controller.show()
    }

    var count: Int { controllers.count }
}

/// Owns one origami's floating window.
final class OrigamiPanelController {
    private let panel: FloatingPanel
    private let origami: Origami
    private let onClose: (UUID) -> Void
    private let size: CGFloat = 110

    init(origami: Origami, noteFrame: NSRect, onClose: @escaping (UUID) -> Void) {
        self.origami = origami
        self.onClose = onClose

        panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: size, height: size))
        panel.minSize = NSSize(width: size, height: size)

        let root = OrigamiView(
            origami: origami,
            onDelete: { [weak self] in self?.dissipate() },
            onChangeColor: { [weak self] in self?.cycleColor() }
        )
        panel.contentView = NSHostingView(rootView: root)

        // Land where the note was, centered.
        let x = noteFrame.midX - size / 2
        let y = noteFrame.midY - size / 2
        panel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    /// Cycle to the next paper color.
    private func cycleColor() {
        let all = NoteColor.allCases
        if let idx = all.firstIndex(of: origami.colorName) {
            origami.colorName = all[(idx + 1) % all.count]
        }
    }

    /// The dissipate send-off: fade the whole thing to nothing, then remove it.
    private func dissipate() {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 1.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            guard let self = self else { return }
            self.panel.close()
            self.onClose(self.origami.id)
        })
    }
}

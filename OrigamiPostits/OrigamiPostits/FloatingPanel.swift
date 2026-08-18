import AppKit
import SwiftUI
import Combine

// MARK: - Floating, transparent, draggable panel
//
// A borderless NSPanel that floats above other windows, shows on every Space,
// has a clear background (so the note's rounded shape shows through), and can be
// dragged from anywhere on its background.

final class FloatingPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )
        isFloatingPanel = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovableByWindowBackground = true   // drag the note from anywhere
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true                     // soft shadow follows the rounded shape
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isReleasedWhenClosed = false
        minSize = NSSize(width: 200, height: 200)
    }

    // Borderless panels need this to accept keyboard focus (typing into fields).
    override var canBecomeKey: Bool { true }
}

/// Owns one panel + its note, and hosts the SwiftUI view inside the panel.
final class NotePanelController {
    private let panel: FloatingPanel
    let note: StickyNote
    private let onClose: (UUID) -> Void

    init(note: StickyNote, onClose: @escaping (UUID) -> Void) {
        self.note = note
        self.onClose = onClose

        let frame = NSRect(x: 0, y: 0, width: 240, height: 280)
        panel = FloatingPanel(contentRect: frame)

        let root = NoteView(note: note, onClose: { [weak self] in self?.close() })
        panel.contentView = NSHostingView(rootView: root)

        // Drop it somewhere near the middle of the screen, with a little scatter
        // so stacked new notes don't land exactly on top of each other.
        if let screen = NSScreen.main {
            let vf = screen.visibleFrame
            let x = vf.midX + CGFloat.random(in: -140...140)
            let y = vf.midY + CGFloat.random(in: -100...100)
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func close() {
        panel.close()
        onClose(note.id)
    }
}

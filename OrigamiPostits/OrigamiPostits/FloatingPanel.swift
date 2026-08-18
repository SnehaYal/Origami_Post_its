import AppKit
import SwiftUI
import Combine

// MARK: - Floating, transparent, draggable panel
//
// A borderless NSPanel that floats above other windows on its own desktop,
// has a clear background (so the note's rounded shape shows), and can be
// dragged from anywhere on its background.

final class FloatingPanel: NSPanel {
    /// `activating: true` makes the panel take focus and become key on click —
    /// needed for interactive surfaces (like the folding view) so SwiftUI drag
    /// gestures keep working. Notes stay non-activating so they don't steal focus.
    init(contentRect: NSRect, activating: Bool = false) {
        var mask: NSWindow.StyleMask = [.borderless, .resizable]
        if !activating { mask.insert(.nonactivatingPanel) }
        super.init(
            contentRect: contentRect,
            styleMask: mask,
            backing: .buffered,
            defer: false
        )
        isFloatingPanel = true
        level = .floating
        // .managed keeps the window pinned to the desktop/Space it was created on,
        // so notes don't follow you when you switch Spaces.
        collectionBehavior = [.managed]
        isMovableByWindowBackground = true   // drag the note from anywhere
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isReleasedWhenClosed = false
        minSize = NSSize(width: 200, height: 200)
    }

    // Borderless panels need these to accept focus (typing, reliable gestures).
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

// MARK: - Note window controller

/// Owns one note's panel, reports moves/tucks to the manager, and hosts the
/// SwiftUI note view.
final class NotePanelController: NSObject, NSWindowDelegate {
    private let panel: FloatingPanel
    let note: StickyNote
    private weak var manager: NoteManager?
    private var isClosing = false
    private var acceptsMove = false     // ignore the initial programmatic move

    init(note: StickyNote, origin: NSPoint?, manager: NoteManager) {
        self.note = note
        self.manager = manager
        panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 240, height: 280))
        super.init()
        panel.delegate = self

        let root = NoteView(
            note: note,
            onClose: { [weak self] in self?.requestClose() },
            onFold:  { [weak self] in self?.fold() },
            onTuck:  { [weak self] in self?.requestTuck() }
        )
        panel.contentView = NSHostingView(rootView: root)

        if let origin = origin {
            panel.setFrameOrigin(origin)
        } else if let screen = NSScreen.main {
            let vf = screen.visibleFrame
            let x = vf.midX + CGFloat.random(in: -140...140)
            let y = vf.midY + CGFloat.random(in: -100...100)
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    var origin: CGPoint { panel.frame.origin }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.acceptsMove = true
        }
    }

    func closePanel() {
        isClosing = true
        panel.delegate = nil
        panel.close()
    }

    private func requestClose() { manager?.removeNote(note.id) }
    private func requestTuck() { manager?.tuck(note.id) }

    /// Picker → hands-on fold → drop the origami, then remove the note.
    func fold() {
        let frame = panel.frame
        let color = note.colorName
        FoldCoordinator.shared.present(colorName: color, near: frame) { [weak self] type in
            guard let self = self else { return }
            FoldingCoordinator.shared.present(type: type, colorName: color, near: frame) {
                OrigamiManager.shared.spawn(type: type, color: color, at: frame)
                self.manager?.removeNote(self.note.id)
            }
        }
    }

    // Track moves for persistence; drag to the left edge to tuck away.
    func windowDidMove(_ notification: Notification) {
        guard acceptsMove, !isClosing else { return }
        let o = panel.frame.origin
        manager?.noteMoved(note.id, to: o)
        if let screen = panel.screen ?? NSScreen.main,
           o.x <= screen.visibleFrame.minX + 4 {
            manager?.tuck(note.id)
        }
    }
}


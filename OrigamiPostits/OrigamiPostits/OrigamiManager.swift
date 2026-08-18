import AppKit
import SwiftUI
import Combine
import QuartzCore

// MARK: - Origami manager
//
// Spawns folded origamis onto the desktop, keeps their windows alive, and
// saves/loads them to disk.

final class OrigamiManager {
    static let shared = OrigamiManager()
    private var origamis: [Origami] = []
    private var controllers: [UUID: OrigamiPanelController] = [:]
    private var saveWork: DispatchWorkItem?
    private let size: CGFloat = 110
    private init() {}

    func load() {
        for dto in Persistence.loadOrigamis() {
            let o = Origami(dto: dto)
            origamis.append(o)
            let c = OrigamiPanelController(
                origami: o,
                origin: NSPoint(x: o.position.x, y: o.position.y),
                manager: self
            )
            controllers[o.id] = c
            c.show()
        }
    }

    func spawn(type: OrigamiType, color: NoteColor, at noteFrame: NSRect) {
        let pos = CGPoint(x: noteFrame.midX - size / 2, y: noteFrame.midY - size / 2)
        let o = Origami(type: type, colorName: color, position: pos)
        origamis.append(o)
        let c = OrigamiPanelController(origami: o, origin: NSPoint(x: pos.x, y: pos.y), manager: self)
        controllers[o.id] = c
        c.show()
        scheduleSave()
    }

    func remove(_ id: UUID) {
        controllers[id] = nil
        origamis.removeAll { $0.id == id }
        scheduleSave()
    }

    func saveNow() {
        Persistence.saveOrigamis(origamis.map { $0.dto })
    }

    func scheduleSave() {
        saveWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.saveNow() }
        saveWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
    }
}

/// Owns one origami's floating window.
final class OrigamiPanelController: NSObject, NSWindowDelegate {
    private let panel: FloatingPanel
    private let origami: Origami
    private weak var manager: OrigamiManager?
    private let size: CGFloat = 110
    private var isClosing = false
    private var acceptsMove = false

    init(origami: Origami, origin: NSPoint, manager: OrigamiManager) {
        self.origami = origami
        self.manager = manager
        panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: size, height: size))
        panel.minSize = NSSize(width: size, height: size)
        super.init()
        panel.delegate = self

        let root = OrigamiView(
            origami: origami,
            onDelete: { [weak self] in self?.dissipate() },
            onChangeColor: { [weak self] in self?.cycleColor() }
        )
        panel.contentView = NSHostingView(rootView: root)
        panel.setFrameOrigin(origin)
    }

    var origin: CGPoint { panel.frame.origin }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.acceptsMove = true
        }
    }

    private func cycleColor() {
        let all = NoteColor.allCases
        if let idx = all.firstIndex(of: origami.colorName) {
            origami.colorName = all[(idx + 1) % all.count]
        }
        manager?.saveNow()
    }

    /// The dissipate send-off: fade to nothing, then remove it.
    private func dissipate() {
        isClosing = true
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 1.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            guard let self = self else { return }
            self.panel.delegate = nil
            self.panel.close()
            self.manager?.remove(self.origami.id)
        })
    }

    func windowDidMove(_ notification: Notification) {
        guard acceptsMove, !isClosing else { return }
        origami.position = panel.frame.origin
        manager?.scheduleSave()
    }
}

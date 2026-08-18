import AppKit
import SwiftUI
import Combine

// MARK: - Note manager
//
// The single source of truth for notes: creates/closes their windows, handles
// tucking to the left-edge tray, and saves/loads everything to disk.

final class NoteManager: ObservableObject {
    static let shared = NoteManager()

    /// Lightweight snapshots of the tucked notes, for the tray UI.
    @Published private(set) var tucked: [TuckedSnapshot] = []

    private var notes: [StickyNote] = []
    private var controllers: [UUID: NotePanelController] = [:]
    private lazy var tray = TrayController(manager: self)
    private var saveWork: DispatchWorkItem?

    private init() {}

    // MARK: Load / create

    func load() {
        let dtos = Persistence.loadNotes()
        if dtos.isEmpty {
            newNote()               // first run — start with one note
            return
        }
        for dto in dtos {
            let note = StickyNote(dto: dto)
            notes.append(note)
            if !note.isTucked {
                let c = NotePanelController(
                    note: note,
                    origin: NSPoint(x: note.position.x, y: note.position.y),
                    manager: self
                )
                controllers[note.id] = c
                c.show()
            }
        }
        rebuildTucked()
    }

    @discardableResult
    func newNote() -> StickyNote {
        let note = StickyNote()
        notes.append(note)
        let c = NotePanelController(note: note, origin: nil, manager: self)
        controllers[note.id] = c
        c.show()
        note.position = c.origin
        scheduleSave()
        return note
    }

    // MARK: Mutations

    private func note(_ id: UUID) -> StickyNote? { notes.first { $0.id == id } }

    func removeNote(_ id: UUID) {
        controllers[id]?.closePanel()
        controllers[id] = nil
        notes.removeAll { $0.id == id }
        rebuildTucked()
        scheduleSave()
    }

    func noteMoved(_ id: UUID, to origin: CGPoint) {
        note(id)?.position = origin
        scheduleSave()
    }

    func tuck(_ id: UUID) {
        guard let n = note(id), !n.isTucked else { return }
        if let c = controllers[id] { n.position = c.origin }   // remember where it was
        n.isTucked = true
        controllers[id]?.closePanel()
        controllers[id] = nil
        rebuildTucked()
        scheduleSave()
    }

    func untuck(id: UUID) {
        guard let n = note(id), n.isTucked else { return }
        n.isTucked = false
        // Keep it clear of the left edge so it doesn't instantly re-tuck.
        var p = n.position
        if let screen = NSScreen.main {
            let minSafe = screen.visibleFrame.minX + 160
            if p.x < minSafe { p.x = minSafe }
        }
        n.position = p
        let c = NotePanelController(note: n, origin: NSPoint(x: p.x, y: p.y), manager: self)
        controllers[id] = c
        c.show()
        rebuildTucked()
        scheduleSave()
    }

    func tuckAll() {
        for n in notes where !n.isTucked { tuck(n.id) }
    }

    func bringAll() {
        for n in notes where n.isTucked { untuck(id: n.id) }
    }

    // MARK: Tray snapshots

    private func rebuildTucked() {
        tucked = notes.filter { $0.isTucked }.map { n in
            let firstLine = n.text.split(whereSeparator: { $0.isNewline }).first.map(String.init) ?? ""
            let title = !firstLine.isEmpty ? firstLine : (n.items.first?.text ?? "Note")
            return TuckedSnapshot(
                id: n.id,
                color: n.colorName,
                title: title,
                total: n.items.count,
                done: n.items.filter { $0.isDone }.count
            )
        }
        tray.sync(count: tucked.count)
    }

    // MARK: Save

    func saveNow() {
        Persistence.saveNotes(notes.map { $0.dto })
    }

    private func scheduleSave() {
        saveWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.saveNow() }
        saveWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
    }
}

/// A compact view-model of one tucked note, shown in the tray.
struct TuckedSnapshot: Identifiable, Equatable {
    let id: UUID
    let color: NoteColor
    let title: String
    let total: Int
    let done: Int
}

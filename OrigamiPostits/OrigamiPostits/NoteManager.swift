import AppKit

// MARK: - Note manager
//
// Keeps every open note's controller alive and cleans up when one is closed.
// This is where we'll later add stacking, search, and persistence.

final class NoteManager {
    static let shared = NoteManager()
    private var controllers: [UUID: NotePanelController] = [:]

    private init() {}

    @discardableResult
    func newNote() -> StickyNote {
        let note = StickyNote()
        let controller = NotePanelController(note: note) { [weak self] id in
            self?.controllers[id] = nil
        }
        controllers[note.id] = controller
        controller.show()
        return note
    }

    var openNoteCount: Int { controllers.count }
}

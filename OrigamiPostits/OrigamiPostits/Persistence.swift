import Foundation

// MARK: - On-disk persistence
//
// Notes and origamis are saved as JSON in Application Support, so everything
// comes back where you left it after quitting — including which notes are tucked.

enum AppPaths {
    static var dir: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let d = base.appendingPathComponent("OrigamiPostits", isDirectory: true)
        try? FileManager.default.createDirectory(at: d, withIntermediateDirectories: true)
        return d
    }
    static var notesFile: URL { dir.appendingPathComponent("notes.json") }
    static var origamisFile: URL { dir.appendingPathComponent("origamis.json") }
}

struct ChecklistItemDTO: Codable {
    var id: UUID
    var text: String
    var isDone: Bool
}

struct NoteDTO: Codable {
    var id: UUID
    var text: String
    var items: [ChecklistItemDTO]
    var color: String
    var x: Double
    var y: Double
    var isTucked: Bool
}

struct OrigamiDTO: Codable {
    var id: UUID
    var type: String
    var color: String
    var x: Double
    var y: Double
}

enum Persistence {
    static func saveNotes(_ notes: [NoteDTO]) {
        if let data = try? JSONEncoder().encode(notes) {
            try? data.write(to: AppPaths.notesFile)
        }
    }

    static func loadNotes() -> [NoteDTO] {
        guard let data = try? Data(contentsOf: AppPaths.notesFile),
              let notes = try? JSONDecoder().decode([NoteDTO].self, from: data) else { return [] }
        return notes
    }

    static func saveOrigamis(_ items: [OrigamiDTO]) {
        if let data = try? JSONEncoder().encode(items) {
            try? data.write(to: AppPaths.origamisFile)
        }
    }

    static func loadOrigamis() -> [OrigamiDTO] {
        guard let data = try? Data(contentsOf: AppPaths.origamisFile),
              let items = try? JSONDecoder().decode([OrigamiDTO].self, from: data) else { return [] }
        return items
    }
}

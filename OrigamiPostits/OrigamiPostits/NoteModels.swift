import SwiftUI
import Combine

// MARK: - Data models

/// A single sticky note. ObservableObject so the SwiftUI view updates live.
final class StickyNote: ObservableObject, Identifiable {
    let id: UUID
    @Published var text: String
    @Published var items: [ChecklistItem]
    @Published var colorName: NoteColor
    /// True once every to-do is checked — drives the "ready to fold" nudge.
    @Published var isReadyToFold: Bool = false
    /// True when the note is stashed in the left-edge tray.
    @Published var isTucked: Bool
    /// Last known screen origin (for restoring position across launches).
    var position: CGPoint

    init(id: UUID = UUID(),
         text: String = "",
         items: [ChecklistItem] = [],
         colorName: NoteColor = .yellow,
         isTucked: Bool = false,
         position: CGPoint = CGPoint(x: 0, y: 0)) {
        self.id = id
        self.text = text
        self.items = items
        self.colorName = colorName
        self.isTucked = isTucked
        self.position = position
        self.isReadyToFold = !items.isEmpty && items.allSatisfy { $0.isDone }
    }

    convenience init(dto: NoteDTO) {
        self.init(
            id: dto.id,
            text: dto.text,
            items: dto.items.map { ChecklistItem(id: $0.id, text: $0.text, isDone: $0.isDone) },
            colorName: NoteColor(rawValue: dto.color) ?? .yellow,
            isTucked: dto.isTucked,
            position: CGPoint(x: dto.x, y: dto.y)
        )
    }

    var dto: NoteDTO {
        NoteDTO(
            id: id,
            text: text,
            items: items.map { ChecklistItemDTO(id: $0.id, text: $0.text, isDone: $0.isDone) },
            color: colorName.rawValue,
            x: Double(position.x),
            y: Double(position.y),
            isTucked: isTucked
        )
    }
}

/// One to-do line inside a note.
struct ChecklistItem: Identifiable, Hashable, Codable {
    var id: UUID = UUID()
    var text: String
    var isDone: Bool = false
}

/// The classic sticky palette. `color` gives the paper tint; this same color
/// becomes the origami's paper color when the note is folded.
enum NoteColor: String, CaseIterable, Identifiable, Codable {
    case yellow, pink, blue, green, purple

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .yellow: return Color(red: 1.00, green: 0.90, blue: 0.45)
        case .pink:   return Color(red: 1.00, green: 0.72, blue: 0.79)
        case .blue:   return Color(red: 0.68, green: 0.85, blue: 1.00)
        case .green:  return Color(red: 0.75, green: 0.93, blue: 0.68)
        case .purple: return Color(red: 0.83, green: 0.75, blue: 0.98)
        }
    }
}

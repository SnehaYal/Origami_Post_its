import SwiftUI
import Combine

// MARK: - Data models

/// A single sticky note. ObservableObject so the SwiftUI view updates live.
final class StickyNote: ObservableObject, Identifiable {
    let id = UUID()
    @Published var text: String = ""
    @Published var items: [ChecklistItem] = []
    @Published var colorName: NoteColor = .yellow
    /// True once every to-do is checked — drives the "ready to fold" nudge.
    @Published var isReadyToFold: Bool = false
}

/// One to-do line inside a note.
struct ChecklistItem: Identifiable, Hashable {
    let id = UUID()
    var text: String
    var isDone: Bool = false
}

/// The classic sticky palette. `color` gives the paper tint; this same color
/// will later become the origami's paper color when the note is folded.
enum NoteColor: String, CaseIterable, Identifiable {
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

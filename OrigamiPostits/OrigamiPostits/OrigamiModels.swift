import SwiftUI
import Combine

// MARK: - Origami models

/// The origami kinds available in v1. Emoji are placeholders for now — real
/// folded-paper art replaces these later.
enum OrigamiType: String, CaseIterable, Identifiable {
    case swan, sailboat, butterfly, pinwheel

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .swan:      "Swan"
        case .sailboat:  "Sailboat"
        case .butterfly: "Butterfly"
        case .pinwheel:  "Pinwheel"
        }
    }

    var emoji: String {
        switch self {
        case .swan:      "🦢"
        case .sailboat:  "⛵"
        case .butterfly: "🦋"
        case .pinwheel:  "🌀"
        }
    }
}

/// A folded origami now living on the desktop. ObservableObject so its color
/// can change live from the context menu.
final class Origami: ObservableObject, Identifiable {
    let id = UUID()
    let type: OrigamiType
    @Published var colorName: NoteColor

    init(type: OrigamiType, colorName: NoteColor) {
        self.type = type
        self.colorName = colorName
    }
}

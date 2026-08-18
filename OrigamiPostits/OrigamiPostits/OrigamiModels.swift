import SwiftUI
import Combine

// MARK: - Origami models

/// The origami kinds available in v1. Emoji are placeholders for now — real
/// folded-paper art replaces these later.
enum OrigamiType: String, CaseIterable, Identifiable, Codable {
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
    let id: UUID
    let type: OrigamiType
    @Published var colorName: NoteColor
    /// Last known screen origin (for restoring position across launches).
    var position: CGPoint

    init(id: UUID = UUID(),
         type: OrigamiType,
         colorName: NoteColor,
         position: CGPoint = CGPoint(x: 0, y: 0)) {
        self.id = id
        self.type = type
        self.colorName = colorName
        self.position = position
    }

    convenience init(dto: OrigamiDTO) {
        self.init(
            id: dto.id,
            type: OrigamiType(rawValue: dto.type) ?? .swan,
            colorName: NoteColor(rawValue: dto.color) ?? .yellow,
            position: CGPoint(x: dto.x, y: dto.y)
        )
    }

    var dto: OrigamiDTO {
        OrigamiDTO(
            id: id,
            type: type.rawValue,
            color: colorName.rawValue,
            x: Double(position.x),
            y: Double(position.y)
        )
    }
}

import AppKit
import SwiftUI
import Combine

// MARK: - "What do you want to make right now?" picker
//
// A small floating panel with the four origami choices. Picking one folds the
// note into that origami; "Not yet" just dismisses.

struct FoldPickerView: View {
    let colorName: NoteColor
    var onPick: (OrigamiType) -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            Text("What do you want to make right now?")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.8))

            HStack(spacing: 12) {
                ForEach(OrigamiType.allCases) { type in
                    Button {
                        onPick(type)
                    } label: {
                        VStack(spacing: 6) {
                            Text(type.emoji).font(.system(size: 32))
                            Text(type.displayName)
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(.black.opacity(0.7))
                        }
                        .frame(width: 74, height: 74)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.5))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }

            Button("Not yet", action: onCancel)
                .buttonStyle(.plain)
                .font(.system(size: 12, design: .rounded))
                .foregroundColor(.black.opacity(0.45))
        }
        .padding(18)
        .frame(width: 380, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(colorName.color)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }
}

// MARK: - Picker panel + coordinator

final class FoldPickerController {
    private let panel: FloatingPanel

    init(colorName: NoteColor,
         near noteFrame: NSRect,
         onPick: @escaping (OrigamiType) -> Void,
         onCancel: @escaping () -> Void) {

        panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 380, height: 200))
        panel.minSize = NSSize(width: 380, height: 200)

        let root = FoldPickerView(colorName: colorName, onPick: onPick, onCancel: onCancel)
        panel.contentView = NSHostingView(rootView: root)

        if let screen = NSScreen.main {
            let vf = screen.visibleFrame
            let x = min(max(noteFrame.midX - 190, vf.minX + 20), vf.maxX - 400)
            let y = min(max(noteFrame.midY - 100, vf.minY + 20), vf.maxY - 220)
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func close() { panel.close() }
}

/// Keeps the current picker alive and ensures only one is open at a time.
final class FoldCoordinator {
    static let shared = FoldCoordinator()
    private var current: FoldPickerController?
    private init() {}

    func present(colorName: NoteColor,
                 near noteFrame: NSRect,
                 onPick: @escaping (OrigamiType) -> Void) {
        current?.close()
        let controller = FoldPickerController(
            colorName: colorName,
            near: noteFrame,
            onPick: { [weak self] type in
                onPick(type)
                self?.current?.close()
                self?.current = nil
            },
            onCancel: { [weak self] in
                self?.current?.close()
                self?.current = nil
            }
        )
        current = controller
        controller.show()
    }
}

import AppKit
import SwiftUI

// MARK: - Floating "add post-it" launcher
//
// A little post-it-shaped "+" button parked in a screen corner. Click it to
// make a new note; right-click for more actions. You can also drag it to
// reposition the launcher.

struct AddButtonView: View {
    var onAdd: () -> Void
    @State private var hover = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(NoteColor.yellow.color)
                .rotationEffect(.degrees(-6))
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.black.opacity(0.55))
        }
        .frame(width: 42, height: 42)
        .scaleEffect(hover ? 1.08 : 1.0)
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 3)
        .padding(9)
        .contentShape(Rectangle())
        .onHover { h in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { hover = h }
        }
        .onTapGesture { onAdd() }
        .contextMenu {
            Button("New Note") { onAdd() }
            Divider()
            Button("Tuck All Away") { NoteManager.shared.tuckAll() }
            Button("Bring All Back") { NoteManager.shared.bringAll() }
        }
        .help("New post-it (right-click for more)")
    }
}

final class AddButtonController {
    static let shared = AddButtonController()
    private var panel: FloatingPanel?
    private init() {}

    func show() {
        if panel == nil {
            let p = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 60, height: 60))
            p.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            p.hasShadow = false
            p.isMovableByWindowBackground = true   // drag to reposition the launcher
            p.contentView = NSHostingView(
                rootView: AddButtonView(onAdd: { NoteManager.shared.newNote() })
            )
            if let screen = NSScreen.main {
                let vf = screen.visibleFrame
                p.setFrameOrigin(NSPoint(x: vf.maxX - 76, y: vf.minY + 24))
            }
            panel = p
        }
        panel?.orderFrontRegardless()
    }
}

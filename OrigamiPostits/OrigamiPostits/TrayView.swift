import AppKit
import SwiftUI
import Combine

// MARK: - Left-edge tray of tucked notes
//
// Tucked notes appear as fanned mini-thumbnails down the left edge. Hover one
// to enlarge/preview it; click it to bring it back onto the desktop.

struct TrayView: View {
    @ObservedObject var manager: NoteManager
    @State private var hovered: UUID? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: -24) {   // negative spacing = fanned overlap
            ForEach(manager.tucked) { snap in
                thumb(snap)
                    .zIndex(hovered == snap.id ? 10 : 0)
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private func thumb(_ snap: TuckedSnapshot) -> some View {
        let isHover = hovered == snap.id
        VStack(alignment: .leading, spacing: 4) {
            Text(snap.title.isEmpty ? "Note" : snap.title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .lineLimit(isHover ? 3 : 1)
                .foregroundColor(.black.opacity(0.78))
            if snap.total > 0 {
                Text("\(snap.done)/\(snap.total) done")
                    .font(.system(size: 9, design: .rounded))
                    .foregroundColor(.black.opacity(0.5))
            }
        }
        .padding(8)
        .frame(width: isHover ? 172 : 84,
               height: isHover ? 92 : 52,
               alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .fill(snap.color.color)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .stroke(Color.black.opacity(0.08), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: isHover ? 8 : 4, x: 2, y: 3)
        .rotationEffect(.degrees(isHover ? 0 : -5), anchor: .topLeading)
        .onHover { inside in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                if inside { hovered = snap.id }
                else if hovered == snap.id { hovered = nil }
            }
        }
        .onTapGesture { manager.untuck(id: snap.id) }
        .help("Click to bring this note back")
    }
}

/// A left-edge window that shows the tray. Present on all Spaces so tucked
/// notes are always reachable.
final class TrayController {
    private let panel: FloatingPanel

    init(manager: NoteManager) {
        panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 210, height: 400))
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hasShadow = false
        panel.isMovableByWindowBackground = false
        panel.contentView = NSHostingView(rootView: TrayView(manager: manager))
    }

    func sync(count: Int) {
        if count == 0 {
            panel.orderOut(nil)
            return
        }
        if let screen = NSScreen.main {
            let vf = screen.visibleFrame
            let h = min(vf.height - 80, CGFloat(count) * 46 + 90)
            let w: CGFloat = 210
            let x = vf.minX + 6
            let y = vf.midY - h / 2
            panel.setFrame(NSRect(x: x, y: y, width: w, height: h), display: true)
        }
        panel.orderFrontRegardless()
    }
}

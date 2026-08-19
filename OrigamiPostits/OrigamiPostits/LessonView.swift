import AppKit
import SwiftUI
import Combine

// MARK: - Learn-to-fold lesson view
//
// Renders the current step's paper state (faces) with dashed crease lines and
// direction arrows, plus the instruction. Drag on the paper to perform the fold
// and advance. "Show me" replays the arrows; "Skip to end" jumps to the finish.

struct LessonView: View {
    let type: OrigamiType
    let colorName: NoteColor
    let steps: [LessonStep]
    var onComplete: () -> Void
    var onCancel: () -> Void

    private let side: CGFloat = 280

    @State private var step = 0
    @State private var pulse = false

    private var current: LessonStep { steps[step] }
    private var actionCount: Int { steps.count - 1 }   // last step is the finished state

    var body: some View {
        VStack(spacing: 10) {
            Text(current.done ? "Done!" : "Step \(step + 1) of \(actionCount)")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.black.opacity(0.5))

            Text(current.instruction)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundColor(.black.opacity(0.85))
                .frame(height: 44)
                .fixedSize(horizontal: false, vertical: true)

            diagram
                .frame(width: side, height: side)
                .contentShape(Rectangle())
                .gesture(advanceDrag)
                .onHover { inside in
                    if inside && !current.done { NSCursor.openHand.set() }
                    else { NSCursor.arrow.set() }
                }

            if !current.done {
                Text(current.action == .reshape
                     ? "Open / press as shown, then drag to continue"
                     : "Fold along the dashed line — drag to continue")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.black.opacity(0.4))
            }

            HStack {
                Button("Cancel") { onCancel() }
                    .buttonStyle(.plain)
                    .foregroundColor(.black.opacity(0.5))
                    .font(.system(size: 13, design: .rounded))
                Spacer()
                if current.done {
                    Button("Place it on my desktop") { onComplete() }
                        .buttonStyle(.plain)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.black.opacity(0.8))
                } else {
                    Button("Show me") { showMe() }
                        .buttonStyle(.plain)
                        .foregroundColor(.black.opacity(0.55))
                        .font(.system(size: 13, design: .rounded))
                    Spacer().frame(width: 14)
                    Button("Skip to end") { skipToEnd() }
                        .buttonStyle(.plain)
                        .foregroundColor(.black.opacity(0.55))
                        .font(.system(size: 13, design: .rounded))
                }
            }
            .padding(.horizontal, 4)
        }
        .padding(20)
        .frame(width: 340, height: 470)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(white: 0.97))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: Diagram

    private var diagram: some View {
        Canvas { ctx, size in
            let s = min(size.width, size.height)
            let ox = (size.width - s) / 2
            let oy = (size.height - s) / 2
            func P(_ u: CGPoint) -> CGPoint { CGPoint(x: ox + u.x * s, y: oy + u.y * s) }
            func poly(_ pts: [CGPoint]) -> Path {
                var p = Path(); p.addLines(pts.map(P)); p.closeSubpath(); return p
            }

            // paper faces
            for face in current.faces {
                ctx.fill(poly(face.points), with: .color(colorName.color))
                if face.shade > 0 {
                    ctx.fill(poly(face.points), with: .color(.black.opacity(face.shade)))
                }
                ctx.stroke(poly(face.points), with: .color(.black.opacity(0.20)), lineWidth: 1.2)
            }

            // crease lines (dashed)
            for cr in current.creases where cr.count == 2 {
                var line = Path(); line.move(to: P(cr[0])); line.addLine(to: P(cr[1]))
                ctx.stroke(line, with: .color(.blue.opacity(0.55)),
                           style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
            }

            // direction arrows (with a little arrowhead)
            let arrowColor = Color.blue.opacity(pulse ? 0.35 : 0.8)
            for a in current.arrows {
                let fpt = P(a.from), tpt = P(a.to)
                var line = Path(); line.move(to: fpt); line.addLine(to: tpt)
                ctx.stroke(line, with: .color(arrowColor),
                           style: StrokeStyle(lineWidth: 3, lineCap: .round))
                let ang = atan2(tpt.y - fpt.y, tpt.x - fpt.x)
                let h: CGFloat = 10
                let left = CGPoint(x: tpt.x - h * cos(ang - CGFloat.pi / 7),
                                   y: tpt.y - h * sin(ang - CGFloat.pi / 7))
                let right = CGPoint(x: tpt.x - h * cos(ang + CGFloat.pi / 7),
                                    y: tpt.y - h * sin(ang + CGFloat.pi / 7))
                var head = Path(); head.move(to: left); head.addLine(to: tpt); head.addLine(to: right)
                ctx.stroke(head, with: .color(arrowColor),
                           style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
        }
    }

    // MARK: Interaction

    private var advanceDrag: some Gesture {
        DragGesture(minimumDistance: 18)
            .onEnded { _ in
                guard !current.done else { return }
                advance()
            }
    }

    private func advance() {
        guard step < steps.count - 1 else { return }
        withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) { step += 1 }
    }

    private func skipToEnd() {
        withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) { step = steps.count - 1 }
    }

    private func showMe() {
        withAnimation(.easeInOut(duration: 0.35).repeatCount(4, autoreverses: true)) { pulse.toggle() }
    }
}

// MARK: - Lesson panel + presenter

/// Shared type so the coordinator can hold either a lesson or the generic fold.
protocol FoldPresenter: AnyObject {
    func show()
    func close()
}

final class LessonController: FoldPresenter {
    private let panel: FloatingPanel

    init(type: OrigamiType,
         steps: [LessonStep],
         colorName: NoteColor,
         near noteFrame: NSRect,
         onComplete: @escaping () -> Void,
         onCancel: @escaping () -> Void) {

        panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 340, height: 470),
                              activating: true)
        panel.minSize = NSSize(width: 340, height: 470)
        panel.isMovableByWindowBackground = false

        let root = LessonView(type: type, colorName: colorName, steps: steps,
                              onComplete: onComplete, onCancel: onCancel)
        panel.contentView = NSHostingView(rootView: root)

        if let screen = NSScreen.main {
            let vf = screen.visibleFrame
            let x = min(max(noteFrame.midX - 170, vf.minX + 20), vf.maxX - 360)
            let y = min(max(noteFrame.midY - 235, vf.minY + 20), vf.maxY - 490)
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func close() { panel.close() }
}

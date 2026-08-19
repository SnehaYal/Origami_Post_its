import AppKit
import SwiftUI
import Combine

// MARK: - Hands-on folding, driven by per-origami recipes
//
// You grab (anywhere on the paper) and drag toward the dashed target, releasing
// to set each crease. Each origami has its own sequence of folds (see
// FoldRecipes). When the last fold sets, a sparkle plays and the origami drops
// onto the desktop.

struct FoldingView: View {
    let type: OrigamiType
    let colorName: NoteColor
    var onComplete: () -> Void
    var onCancel: () -> Void

    private let side: CGFloat = 280

    // Unit square corners (SwiftUI coords: y increases downward).
    private let unit: [CGPoint] = [
        CGPoint(x: 0, y: 0), // 0 top-left
        CGPoint(x: 1, y: 0), // 1 top-right
        CGPoint(x: 1, y: 1), // 2 bottom-right
        CGPoint(x: 0, y: 1)  // 3 bottom-left
    ]

    private var steps: [FoldStep] { FoldRecipes.recipe(for: type) }

    @State private var step = 0
    @State private var tip: CGPoint? = nil     // live position of the grabbed corner
    @State private var finished = false
    @State private var sparkle = false

    // Geometry helpers
    private func p(_ u: CGPoint) -> CGPoint { CGPoint(x: u.x * side, y: u.y * side) }
    private func neighbors(_ i: Int) -> (CGPoint, CGPoint) {
        (p(unit[(i + 1) % 4]), p(unit[(i + 3) % 4]))
    }
    private func tri(_ a: CGPoint, _ b: CGPoint, _ c: CGPoint) -> Path {
        var path = Path()
        path.move(to: a); path.addLine(to: b); path.addLine(to: c); path.closeSubpath()
        return path
    }
    private func clamp(_ pt: CGPoint) -> CGPoint {
        CGPoint(x: min(max(pt.x, 0), side), y: min(max(pt.y, 0), side))
    }
    private func dist(_ a: CGPoint, _ b: CGPoint) -> CGFloat { hypot(a.x - b.x, a.y - b.y) }

    private var activeCorner: Int { step < steps.count ? steps[step].grab : -1 }
    private var currentTarget: CGPoint { p(steps[min(step, steps.count - 1)].target) }

    var body: some View {
        VStack(spacing: 14) {
            Text(finished
                 ? "Your \(type.displayName.lowercased()) is ready!"
                 : "Fold the \(type.displayName.lowercased()) — step \(min(step + 1, steps.count)) of \(steps.count)")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.black.opacity(0.8))

            paper
                .frame(width: side, height: side)
                .coordinateSpace(name: "paper")
                .contentShape(Rectangle())
                .gesture(dragGesture)
                .onHover { inside in
                    if inside && !finished { NSCursor.openHand.set() }
                    else { NSCursor.arrow.set() }
                }

            HStack {
                Button("Cancel") { onCancel() }
                    .buttonStyle(.plain)
                    .foregroundColor(.black.opacity(0.5))
                    .font(.system(size: 13, design: .rounded))
                Spacer()
                Button("Fold it for me") { autoComplete() }
                    .buttonStyle(.plain)
                    .foregroundColor(.black.opacity(0.6))
                    .font(.system(size: 13, weight: .medium, design: .rounded))
            }
            .padding(.horizontal, 4)
        }
        .padding(20)
        .frame(width: 340, height: 392)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(white: 0.97))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
    }

    // MARK: Paper drawing

    private var paper: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(colorName.color)
                .frame(width: side, height: side)
                .shadow(color: .black.opacity(0.18), radius: 6, y: 3)

            // Folds already set
            ForEach(Array(0..<step), id: \.self) { idx in
                foldLayer(steps[idx])
            }

            // The corner you're folding right now
            if !finished, activeCorner >= 0 {
                activeLayer(activeCorner)
            }

            if sparkle {
                Image(systemName: "sparkles")
                    .font(.system(size: 64))
                    .foregroundColor(.white)
                    .scaleEffect(sparkle ? 1.35 : 0.4)
                    .opacity(sparkle ? 0 : 1)
            }
        }
    }

    @ViewBuilder
    private func foldLayer(_ s: FoldStep) -> some View {
        let (a, b) = neighbors(s.grab)
        let t = p(s.target)
        ZStack {
            tri(a, t, b).fill(colorName.color)
            tri(a, t, b).fill(Color.black.opacity(0.06))
            Path { pth in pth.move(to: a); pth.addLine(to: b) }
                .stroke(Color.black.opacity(0.15), lineWidth: 1)
        }
    }

    @ViewBuilder
    private func activeLayer(_ i: Int) -> some View {
        let (a, b) = neighbors(i)
        let cornerPt = p(unit[i])
        let tp = tip ?? cornerPt
        ZStack {
            tri(a, tp, b)
                .fill(colorName.color)
                .overlay(tri(a, tp, b).fill(Color.black.opacity(0.05)))
                .shadow(color: .black.opacity(0.12), radius: 3, y: 2)

            Circle()
                .strokeBorder(Color.black.opacity(0.35),
                              style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                .frame(width: 26, height: 26)
                .position(currentTarget)

            Circle()
                .fill(Color.white.opacity(0.9))
                .overlay(Circle().stroke(Color.black.opacity(0.25), lineWidth: 1))
                .frame(width: 22, height: 22)
                .shadow(color: .black.opacity(0.25), radius: 2)
                .position(tp)
        }
    }

    // MARK: Gesture

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0, coordinateSpace: .named("paper"))
            .onChanged { value in
                guard !finished, activeCorner >= 0 else { return }
                // Grab from anywhere on the paper and drag toward the target.
                tip = clamp(value.location)
            }
            .onEnded { value in
                guard !finished, activeCorner >= 0, tip != nil else { return }
                if dist(clamp(value.location), currentTarget) <= 44 {
                    commitFold()
                } else {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) { tip = nil }
                }
            }
    }

    // MARK: Actions

    private func commitFold() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            tip = nil
            step += 1
        }
        if step >= steps.count { finish() }
    }

    private func autoComplete() {
        step = steps.count
        tip = nil
        finish()
    }

    private func finish() {
        finished = true
        withAnimation(.easeOut(duration: 0.8)) { sparkle = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { onComplete() }
    }
}

// MARK: - Folding panel + coordinator

final class FoldingController: FoldPresenter {
    private let panel: FloatingPanel

    init(type: OrigamiType,
         colorName: NoteColor,
         near noteFrame: NSRect,
         onComplete: @escaping () -> Void,
         onCancel: @escaping () -> Void) {

        panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 340, height: 392),
                              activating: true)
        panel.minSize = NSSize(width: 340, height: 392)
        // Let mouse drags reach the paper instead of moving the window.
        panel.isMovableByWindowBackground = false

        let root = FoldingView(type: type, colorName: colorName,
                               onComplete: onComplete, onCancel: onCancel)
        panel.contentView = NSHostingView(rootView: root)

        if let screen = NSScreen.main {
            let vf = screen.visibleFrame
            let x = min(max(noteFrame.midX - 170, vf.minX + 20), vf.maxX - 360)
            let y = min(max(noteFrame.midY - 196, vf.minY + 20), vf.maxY - 412)
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }

    func show() {
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func close() { panel.close() }
}

final class FoldingCoordinator {
    static let shared = FoldingCoordinator()
    private var current: FoldPresenter?
    private init() {}

    func present(type: OrigamiType,
                 colorName: NoteColor,
                 near noteFrame: NSRect,
                 onComplete: @escaping () -> Void) {
        current?.close()

        let complete: () -> Void = { [weak self] in
            onComplete()
            self?.current?.close()
            self?.current = nil
        }
        let cancel: () -> Void = { [weak self] in
            self?.current?.close()
            self?.current = nil
        }

        // Use the real learn-to-fold lesson if we've authored one; otherwise the
        // generic fold mechanic.
        if let steps = OrigamiLessons.lesson(for: type) {
            let controller = LessonController(type: type, steps: steps, colorName: colorName,
                                              near: noteFrame, onComplete: complete, onCancel: cancel)
            current = controller
            controller.show()
        } else {
            let controller = FoldingController(type: type, colorName: colorName,
                                               near: noteFrame, onComplete: complete, onCancel: cancel)
            current = controller
            controller.show()
        }
    }
}

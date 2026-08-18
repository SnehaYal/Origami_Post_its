import SwiftUI

// MARK: - Drawn origami graphics
//
// Simple geometric "papercraft" silhouettes for each origami, tinted with the
// note's color so the paper color still carries through. Drawn with Canvas so
// it scales cleanly at any size (desktop pet, picker thumbnail, etc.).

struct OrigamiGraphic: View {
    let type: OrigamiType
    let color: NoteColor

    var body: some View {
        Canvas { ctx, size in
            let s = min(size.width, size.height)
            let ox = (size.width - s) / 2
            let oy = (size.height - s) / 2
            func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: ox + x * s, y: oy + y * s) }
            func poly(_ pts: [CGPoint]) -> Path {
                var p = Path(); p.addLines(pts); p.closeSubpath(); return p
            }
            func fill(_ pts: [CGPoint], _ shade: Double) {
                ctx.fill(poly(pts), with: .color(color.color))
                if shade > 0 { ctx.fill(poly(pts), with: .color(.black.opacity(shade))) }
            }
            func crease(_ a: CGPoint, _ b: CGPoint) {
                var p = Path(); p.move(to: a); p.addLine(to: b)
                ctx.stroke(p, with: .color(.black.opacity(0.14)), lineWidth: 1)
            }

            switch type {
            case .pinwheel:
                let c = pt(0.5, 0.5)
                // four swept blades, alternating shade for a spinning look
                fill([c, pt(0.0, 0.0), pt(0.5, 0.0)], 0.0)
                fill([c, pt(1.0, 0.0), pt(1.0, 0.5)], 0.10)
                fill([c, pt(1.0, 1.0), pt(0.5, 1.0)], 0.0)
                fill([c, pt(0.0, 1.0), pt(0.0, 0.5)], 0.10)
                ctx.fill(Path(ellipseIn: CGRect(x: c.x - 5, y: c.y - 5, width: 10, height: 10)),
                         with: .color(.black.opacity(0.35)))

            case .sailboat:
                // sail
                fill([pt(0.52, 0.06), pt(0.52, 0.60), pt(0.14, 0.60)], 0.0)
                // second sail (smaller, shaded)
                fill([pt(0.56, 0.16), pt(0.56, 0.60), pt(0.88, 0.60)], 0.10)
                // hull
                fill([pt(0.12, 0.66), pt(0.88, 0.66), pt(0.74, 0.84), pt(0.26, 0.84)], 0.06)
                crease(pt(0.52, 0.10), pt(0.52, 0.60))

            case .swan:
                // body
                fill([pt(0.16, 0.74), pt(0.78, 0.74), pt(0.46, 0.44)], 0.0)
                // tail
                fill([pt(0.16, 0.74), pt(0.04, 0.60), pt(0.22, 0.60)], 0.10)
                // neck
                fill([pt(0.50, 0.56), pt(0.60, 0.56), pt(0.70, 0.22), pt(0.62, 0.20)], 0.05)
                // head + beak
                fill([pt(0.62, 0.20), pt(0.70, 0.22), pt(0.78, 0.28)], 0.0)
                crease(pt(0.46, 0.46), pt(0.58, 0.56))

            case .butterfly:
                // body
                ctx.fill(Path(roundedRect: CGRect(x: pt(0.485, 0.34).x,
                                                  y: pt(0.5, 0.34).y,
                                                  width: s * 0.03,
                                                  height: s * 0.40),
                              cornerSize: CGSize(width: 3, height: 3)),
                         with: .color(.black.opacity(0.30)))
                // upper wings
                fill([pt(0.5, 0.36), pt(0.10, 0.14), pt(0.14, 0.48)], 0.0)
                fill([pt(0.5, 0.36), pt(0.90, 0.14), pt(0.86, 0.48)], 0.10)
                // lower wings
                fill([pt(0.5, 0.52), pt(0.18, 0.54), pt(0.32, 0.82)], 0.10)
                fill([pt(0.5, 0.52), pt(0.82, 0.54), pt(0.68, 0.82)], 0.0)
            }
        }
    }
}

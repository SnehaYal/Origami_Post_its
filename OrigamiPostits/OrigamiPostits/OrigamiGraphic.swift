import SwiftUI

// MARK: - Drawn origami graphics
//
// Geometric "papercraft" silhouettes for each origami, tinted with the note's
// color. Every shape is normalized to fill the same bounding box, so all four
// render at a consistent size.

struct OrigamiGraphic: View {
    let type: OrigamiType
    let color: NoteColor

    struct Shp { let points: [CGPoint]; let shade: Double }

    var body: some View {
        Canvas { ctx, size in
            let shapes = Self.shapes(for: type)

            // Bounding box of all points, so we can normalize to a common size.
            var minX = CGFloat.greatestFiniteMagnitude, minY = minX
            var maxX = -CGFloat.greatestFiniteMagnitude, maxY = maxX
            for s in shapes {
                for p in s.points {
                    minX = min(minX, p.x); minY = min(minY, p.y)
                    maxX = max(maxX, p.x); maxY = max(maxY, p.y)
                }
            }
            let bw = max(maxX - minX, 0.0001)
            let bh = max(maxY - minY, 0.0001)

            let target = CGRect(x: size.width * 0.10, y: size.height * 0.10,
                                width: size.width * 0.80, height: size.height * 0.80)
            let scale = min(target.width / bw, target.height / bh)
            let offX = target.midX - (minX + bw / 2) * scale
            let offY = target.midY - (minY + bh / 2) * scale
            func M(_ p: CGPoint) -> CGPoint { CGPoint(x: p.x * scale + offX, y: p.y * scale + offY) }
            func poly(_ pts: [CGPoint]) -> Path {
                var pa = Path(); pa.addLines(pts.map(M)); pa.closeSubpath(); return pa
            }

            for s in shapes {
                ctx.fill(poly(s.points), with: .color(color.color))
                if s.shade > 0 { ctx.fill(poly(s.points), with: .color(.black.opacity(s.shade))) }
                ctx.stroke(poly(s.points), with: .color(.black.opacity(0.18)), lineWidth: 1)
            }

            if type == .pinwheel {
                let c = M(CGPoint(x: 0.5, y: 0.5))
                ctx.fill(Path(ellipseIn: CGRect(x: c.x - 4, y: c.y - 4, width: 8, height: 8)),
                         with: .color(.black.opacity(0.35)))
            }
        }
    }

    static func shapes(for type: OrigamiType) -> [Shp] {
        func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
        switch type {
        case .pinwheel:
            let c = pt(0.5, 0.5)
            return [
                Shp(points: [c, pt(0.0, 0.0), pt(0.5, 0.0)], shade: 0.0),
                Shp(points: [c, pt(1.0, 0.0), pt(1.0, 0.5)], shade: 0.10),
                Shp(points: [c, pt(1.0, 1.0), pt(0.5, 1.0)], shade: 0.0),
                Shp(points: [c, pt(0.0, 1.0), pt(0.0, 0.5)], shade: 0.10)
            ]
        case .sailboat:
            return [
                Shp(points: [pt(0.52, 0.06), pt(0.52, 0.60), pt(0.14, 0.60)], shade: 0.0),
                Shp(points: [pt(0.56, 0.16), pt(0.56, 0.60), pt(0.88, 0.60)], shade: 0.10),
                Shp(points: [pt(0.12, 0.66), pt(0.88, 0.66), pt(0.74, 0.84), pt(0.26, 0.84)], shade: 0.06)
            ]
        case .swan:
            return [
                Shp(points: [pt(0.16, 0.74), pt(0.78, 0.74), pt(0.46, 0.44)], shade: 0.0),
                Shp(points: [pt(0.16, 0.74), pt(0.04, 0.60), pt(0.22, 0.60)], shade: 0.10),
                Shp(points: [pt(0.50, 0.56), pt(0.60, 0.56), pt(0.70, 0.22), pt(0.62, 0.20)], shade: 0.05),
                Shp(points: [pt(0.62, 0.20), pt(0.70, 0.22), pt(0.78, 0.28)], shade: 0.0)
            ]
        case .butterfly:
            return [
                Shp(points: [pt(0.485, 0.34), pt(0.515, 0.34), pt(0.515, 0.74), pt(0.485, 0.74)], shade: 0.30),
                Shp(points: [pt(0.5, 0.36), pt(0.10, 0.14), pt(0.14, 0.48)], shade: 0.0),
                Shp(points: [pt(0.5, 0.36), pt(0.90, 0.14), pt(0.86, 0.48)], shade: 0.10),
                Shp(points: [pt(0.5, 0.52), pt(0.18, 0.54), pt(0.32, 0.82)], shade: 0.10),
                Shp(points: [pt(0.5, 0.52), pt(0.82, 0.54), pt(0.68, 0.82)], shade: 0.0)
            ]
        }
    }
}

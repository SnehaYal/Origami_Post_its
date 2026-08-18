import CoreGraphics

// MARK: - Fold recipes
//
// Each origami is an ordered list of folds. A fold grabs one corner of the
// square (0 = top-left, 1 = top-right, 2 = bottom-right, 3 = bottom-left) and
// drags it to a target point in unit coordinates (0…1). Different recipes give
// each origami its own folding sequence and number of steps.

struct FoldStep {
    let grab: Int          // square corner index 0…3
    let target: CGPoint    // unit coords (0…1)
}

enum FoldRecipes {
    static func recipe(for type: OrigamiType) -> [FoldStep] {
        switch type {
        case .pinwheel:
            // Four corners swept toward adjacent edge-midpoints (rotational).
            return [
                FoldStep(grab: 0, target: CGPoint(x: 0.5, y: 0.0)),
                FoldStep(grab: 1, target: CGPoint(x: 1.0, y: 0.5)),
                FoldStep(grab: 2, target: CGPoint(x: 0.5, y: 1.0)),
                FoldStep(grab: 3, target: CGPoint(x: 0.0, y: 0.5))
            ]
        case .sailboat:
            // A quick two folds: big diagonal (the sail), then the hull up.
            return [
                FoldStep(grab: 3, target: CGPoint(x: 1.0, y: 0.0)),
                FoldStep(grab: 2, target: CGPoint(x: 0.5, y: 0.5))
            ]
        case .swan:
            // Fold both top corners into the middle, then form the neck.
            return [
                FoldStep(grab: 0, target: CGPoint(x: 0.5, y: 0.5)),
                FoldStep(grab: 3, target: CGPoint(x: 0.5, y: 0.5)),
                FoldStep(grab: 1, target: CGPoint(x: 0.66, y: 0.3))
            ]
        case .butterfly:
            // Fold in half, then bring each side up into wings.
            return [
                FoldStep(grab: 2, target: CGPoint(x: 0.0, y: 0.0)),
                FoldStep(grab: 1, target: CGPoint(x: 0.5, y: 0.66)),
                FoldStep(grab: 3, target: CGPoint(x: 0.5, y: 0.66))
            ]
        }
    }
}

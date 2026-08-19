import CoreGraphics

// MARK: - Learn-to-fold lessons
//
// Each origami is an ordered list of steps. A step shows the paper in its
// current state (a set of polygon "faces"), plus the crease line(s) and
// direction arrow(s) for the fold you should make, and an instruction. You
// perform the fold (a drag) to advance to the next step. Some steps are
// "reshape" moves (open a pocket / pull the sides) rather than flat folds.
//
// Coordinates are unit (0…1) inside a square diagram box; y increases downward.

struct LessonFace {
    let points: [CGPoint]
    let shade: Double        // 0 = paper front color; >0 = darker (lower layer / back)
}

struct LessonArrow {
    let from: CGPoint
    let to: CGPoint
}

enum LessonAction { case fold, reshape }

struct LessonStep {
    let instruction: String
    let action: LessonAction
    let faces: [LessonFace]
    let creases: [[CGPoint]]      // each = 2 points (a dashed fold line)
    let arrows: [LessonArrow]
    let done: Bool               // true only for the final "ready" state
}

enum OrigamiLessons {
    /// Returns a real lesson if we've authored one; otherwise nil (falls back to
    /// the generic fold mechanic).
    static func lesson(for type: OrigamiType) -> [LessonStep]? {
        switch type {
        case .sailboat:  return sailboat
        case .swan:      return swan
        case .pinwheel:  return pinwheel
        case .butterfly: return butterfly
        }
    }

    // Helper
    private static func f(_ pts: [(CGFloat, CGFloat)], _ shade: Double = 0) -> LessonFace {
        LessonFace(points: pts.map { CGPoint(x: $0.0, y: $0.1) }, shade: shade)
    }
    private static func c(_ a: (CGFloat, CGFloat), _ b: (CGFloat, CGFloat)) -> [CGPoint] {
        [CGPoint(x: a.0, y: a.1), CGPoint(x: b.0, y: b.1)]
    }
    private static func arw(_ a: (CGFloat, CGFloat), _ b: (CGFloat, CGFloat)) -> LessonArrow {
        LessonArrow(from: CGPoint(x: a.0, y: a.1), to: CGPoint(x: b.0, y: b.1))
    }

    // MARK: Sailboat (traditional)

    static let sailboat: [LessonStep] = [
        // 0 — square → fold in half
        LessonStep(
            instruction: "Fold the square in half — bring the top edge down to the bottom.",
            action: .fold,
            faces: [f([(0.30,0.20),(0.70,0.20),(0.70,0.80),(0.30,0.80)])],
            creases: [c((0.30,0.50),(0.70,0.50))],
            arrows: [arw((0.50,0.28),(0.50,0.72))],
            done: false
        ),
        // 1 — wide rectangle → fold top corners to center (triangle)
        LessonStep(
            instruction: "Fold the two top corners down to meet at the center — making a triangle.",
            action: .fold,
            faces: [f([(0.30,0.50),(0.70,0.50),(0.70,0.80),(0.30,0.80)])],
            creases: [c((0.30,0.50),(0.50,0.70)), c((0.70,0.50),(0.50,0.70))],
            arrows: [arw((0.33,0.52),(0.48,0.66)), arw((0.67,0.52),(0.52,0.66))],
            done: false
        ),
        // 2 — house (triangle + band) → fold band up (hat)
        LessonStep(
            instruction: "Fold the bottom band up over the triangle — front and back — to form a hat.",
            action: .fold,
            faces: [
                f([(0.50,0.50),(0.30,0.70),(0.70,0.70)]),
                f([(0.30,0.70),(0.70,0.70),(0.70,0.80),(0.30,0.80)], 0.08)
            ],
            creases: [c((0.30,0.70),(0.70,0.70))],
            arrows: [arw((0.50,0.78),(0.50,0.63))],
            done: false
        ),
        // 3 — hat → open pocket, press flat into a diamond (reshape)
        LessonStep(
            instruction: "Open the bottom pocket and press the sides together, flattening it into a diamond.",
            action: .reshape,
            faces: [
                f([(0.50,0.52),(0.30,0.72),(0.70,0.72)]),
                f([(0.30,0.72),(0.70,0.72),(0.63,0.66),(0.37,0.66)], 0.12)
            ],
            creases: [],
            arrows: [arw((0.44,0.72),(0.30,0.64)), arw((0.56,0.72),(0.70,0.64))],
            done: false
        ),
        // 4 — diamond → fold bottom point up to top
        LessonStep(
            instruction: "Fold the bottom point up to the top point — front and back.",
            action: .fold,
            faces: [f([(0.50,0.42),(0.68,0.62),(0.50,0.82),(0.32,0.62)])],
            creases: [c((0.32,0.62),(0.68,0.62))],
            arrows: [arw((0.50,0.80),(0.50,0.45))],
            done: false
        ),
        // 5 — triangle → open pocket again, press into a diamond (reshape)
        LessonStep(
            instruction: "Open this pocket too and press it flat into a diamond again.",
            action: .reshape,
            faces: [f([(0.50,0.42),(0.68,0.62),(0.32,0.62)])],
            creases: [],
            arrows: [arw((0.44,0.60),(0.30,0.55)), arw((0.56,0.60),(0.70,0.55))],
            done: false
        ),
        // 6 — small diamond → pull the sides apart into the boat (reshape)
        LessonStep(
            instruction: "Gently pull the two side points apart to open the boat, and lift the sail up.",
            action: .reshape,
            faces: [f([(0.50,0.46),(0.64,0.60),(0.50,0.74),(0.36,0.60)])],
            creases: [],
            arrows: [arw((0.36,0.60),(0.22,0.60)), arw((0.64,0.60),(0.78,0.60))],
            done: false
        ),
        // 7 — finished boat
        LessonStep(
            instruction: "Your sailboat is ready! 🎉",
            action: .fold,
            faces: [
                f([(0.50,0.30),(0.50,0.62),(0.30,0.62)]),
                f([(0.54,0.40),(0.54,0.62),(0.72,0.62)], 0.08),
                f([(0.24,0.62),(0.76,0.62),(0.66,0.78),(0.34,0.78)], 0.05)
            ],
            creases: [],
            arrows: [],
            done: true
        )
    ]

    // MARK: Swan (traditional kite-base)

    static let swan: [LessonStep] = [
        LessonStep(
            instruction: "Fold in half top-to-bottom and unfold — to mark the center line.",
            action: .fold,
            faces: [f([(0.50,0.16),(0.68,0.42),(0.50,0.68),(0.32,0.42)])],
            creases: [c((0.50,0.16),(0.50,0.68))],
            arrows: [arw((0.62,0.30),(0.42,0.50))],
            done: false
        ),
        LessonStep(
            instruction: "Fold the two upper edges in to the center line — like a kite.",
            action: .fold,
            faces: [f([(0.50,0.16),(0.68,0.42),(0.50,0.68),(0.32,0.42)])],
            creases: [c((0.50,0.16),(0.50,0.68))],
            arrows: [arw((0.34,0.34),(0.47,0.37)), arw((0.66,0.34),(0.53,0.37))],
            done: false
        ),
        LessonStep(
            instruction: "Turn the paper over.",
            action: .reshape,
            faces: [f([(0.50,0.16),(0.60,0.42),(0.50,0.70),(0.40,0.42)])],
            creases: [],
            arrows: [],
            done: false
        ),
        LessonStep(
            instruction: "Fold the two upper edges in to the center again.",
            action: .fold,
            faces: [f([(0.50,0.16),(0.60,0.42),(0.50,0.70),(0.40,0.42)])],
            creases: [c((0.50,0.16),(0.50,0.70))],
            arrows: [arw((0.41,0.34),(0.48,0.37)), arw((0.59,0.34),(0.52,0.37))],
            done: false
        ),
        LessonStep(
            instruction: "Lift the long bottom point up to form the neck.",
            action: .reshape,
            faces: [f([(0.50,0.16),(0.57,0.42),(0.50,0.72),(0.43,0.42)])],
            creases: [],
            arrows: [arw((0.50,0.70),(0.50,0.30))],
            done: false
        ),
        LessonStep(
            instruction: "Fold the tip of the neck down to make the head.",
            action: .fold,
            faces: [
                f([(0.40,0.44),(0.60,0.44),(0.54,0.66),(0.46,0.66)]),
                f([(0.47,0.20),(0.53,0.20),(0.52,0.48),(0.48,0.48)], 0.04)
            ],
            creases: [c((0.47,0.24),(0.53,0.24))],
            arrows: [arw((0.50,0.22),(0.62,0.27))],
            done: false
        ),
        LessonStep(
            instruction: "Fold the whole swan in half along the center to stand it up.",
            action: .reshape,
            faces: [
                f([(0.30,0.62),(0.66,0.62),(0.50,0.48)]),
                f([(0.60,0.30),(0.66,0.32),(0.64,0.50),(0.58,0.50)], 0.04),
                f([(0.58,0.30),(0.66,0.32),(0.70,0.38)])
            ],
            creases: [],
            arrows: [arw((0.48,0.66),(0.48,0.42))],
            done: false
        ),
        LessonStep(
            instruction: "Your swan is ready! 🎉",
            action: .fold,
            faces: [
                f([(0.16,0.74),(0.78,0.74),(0.46,0.44)]),
                f([(0.16,0.74),(0.04,0.60),(0.22,0.60)], 0.10),
                f([(0.50,0.56),(0.60,0.56),(0.70,0.22),(0.62,0.20)], 0.05),
                f([(0.62,0.20),(0.70,0.22),(0.78,0.28)])
            ],
            creases: [],
            arrows: [],
            done: true
        )
    ]

    // MARK: Pinwheel (cupboard-fold)

    static let pinwheel: [LessonStep] = [
        LessonStep(
            instruction: "Fold both diagonals and unfold — to mark the creases.",
            action: .fold,
            faces: [f([(0.30,0.24),(0.70,0.24),(0.70,0.64),(0.30,0.64)])],
            creases: [c((0.30,0.24),(0.70,0.64)), c((0.70,0.24),(0.30,0.64))],
            arrows: [],
            done: false
        ),
        LessonStep(
            instruction: "Fold all four corners to the center (a blintz fold), then unfold.",
            action: .fold,
            faces: [f([(0.30,0.24),(0.70,0.24),(0.70,0.64),(0.30,0.64)])],
            creases: [],
            arrows: [
                arw((0.32,0.26),(0.47,0.42)), arw((0.68,0.26),(0.53,0.42)),
                arw((0.32,0.62),(0.47,0.46)), arw((0.68,0.62),(0.53,0.46))
            ],
            done: false
        ),
        LessonStep(
            instruction: "Fold the left and right edges in to the center (a cupboard fold).",
            action: .fold,
            faces: [f([(0.30,0.24),(0.70,0.24),(0.70,0.64),(0.30,0.64)])],
            creases: [c((0.50,0.24),(0.50,0.64))],
            arrows: [arw((0.34,0.44),(0.47,0.44)), arw((0.66,0.44),(0.53,0.44))],
            done: false
        ),
        LessonStep(
            instruction: "At the top, pull the two corners open and pinch them flat into little triangles.",
            action: .reshape,
            faces: [f([(0.40,0.24),(0.60,0.24),(0.60,0.64),(0.40,0.64)])],
            creases: [],
            arrows: [arw((0.44,0.28),(0.36,0.32)), arw((0.56,0.28),(0.64,0.32))],
            done: false
        ),
        LessonStep(
            instruction: "Do the same at the bottom — open and pinch those corners.",
            action: .reshape,
            faces: [
                f([(0.40,0.30),(0.60,0.30),(0.60,0.64),(0.40,0.64)]),
                f([(0.40,0.30),(0.30,0.34),(0.40,0.40)], 0.08),
                f([(0.60,0.30),(0.70,0.34),(0.60,0.40)], 0.08)
            ],
            creases: [],
            arrows: [arw((0.44,0.60),(0.36,0.56)), arw((0.56,0.60),(0.64,0.56))],
            done: false
        ),
        LessonStep(
            instruction: "Fold the top-left flap up along the diagonal.",
            action: .fold,
            faces: [f([(0.30,0.34),(0.70,0.34),(0.74,0.44),(0.70,0.54),(0.30,0.54),(0.26,0.44)])],
            creases: [c((0.30,0.44),(0.50,0.34))],
            arrows: [arw((0.34,0.40),(0.46,0.36))],
            done: false
        ),
        LessonStep(
            instruction: "Fold the bottom-right flap down — your pinwheel is done!",
            action: .fold,
            faces: [f([(0.30,0.34),(0.70,0.34),(0.74,0.44),(0.70,0.54),(0.30,0.54),(0.26,0.44)])],
            creases: [c((0.70,0.44),(0.50,0.54))],
            arrows: [arw((0.66,0.48),(0.54,0.52))],
            done: false
        ),
        LessonStep(
            instruction: "Your pinwheel is ready! 🎉",
            action: .fold,
            faces: [
                f([(0.5,0.5),(0.0,0.0),(0.5,0.0)]),
                f([(0.5,0.5),(1.0,0.0),(1.0,0.5)], 0.10),
                f([(0.5,0.5),(1.0,1.0),(0.5,1.0)]),
                f([(0.5,0.5),(0.0,1.0),(0.0,0.5)], 0.10)
            ],
            creases: [],
            arrows: [],
            done: true
        )
    ]

    // MARK: Butterfly (waterbomb base)

    static let butterfly: [LessonStep] = [
        LessonStep(
            instruction: "Fold in half both ways and unfold.",
            action: .fold,
            faces: [f([(0.30,0.22),(0.70,0.22),(0.70,0.62),(0.30,0.62)])],
            creases: [c((0.50,0.22),(0.50,0.62)), c((0.30,0.42),(0.70,0.42))],
            arrows: [],
            done: false
        ),
        LessonStep(
            instruction: "Turn the paper over, then fold both diagonals and unfold.",
            action: .fold,
            faces: [f([(0.30,0.22),(0.70,0.22),(0.70,0.62),(0.30,0.62)])],
            creases: [c((0.30,0.22),(0.70,0.62)), c((0.70,0.22),(0.30,0.62))],
            arrows: [],
            done: false
        ),
        LessonStep(
            instruction: "Collapse it into a triangle (a waterbomb base): push the sides in and bring the top down.",
            action: .reshape,
            faces: [f([(0.30,0.22),(0.70,0.22),(0.70,0.62),(0.30,0.62)])],
            creases: [],
            arrows: [arw((0.34,0.30),(0.48,0.46)), arw((0.66,0.30),(0.52,0.46))],
            done: false
        ),
        LessonStep(
            instruction: "Fold the two bottom corners of the front layer up to the top point.",
            action: .fold,
            faces: [f([(0.50,0.26),(0.72,0.60),(0.28,0.60)])],
            creases: [c((0.40,0.60),(0.50,0.43)), c((0.60,0.60),(0.50,0.43))],
            arrows: [arw((0.34,0.58),(0.48,0.34)), arw((0.66,0.58),(0.52,0.34))],
            done: false
        ),
        LessonStep(
            instruction: "Turn it over, then fold the top corner down, a little past the bottom edge.",
            action: .fold,
            faces: [f([(0.50,0.26),(0.66,0.46),(0.50,0.62),(0.34,0.46)])],
            creases: [c((0.34,0.42),(0.66,0.42))],
            arrows: [arw((0.50,0.28),(0.50,0.52))],
            done: false
        ),
        LessonStep(
            instruction: "Turn it over and fold in half down the center; pinch the middle so the wings pop up.",
            action: .reshape,
            faces: [f([(0.34,0.40),(0.66,0.40),(0.60,0.62),(0.50,0.56),(0.40,0.62)])],
            creases: [c((0.50,0.34),(0.50,0.62))],
            arrows: [arw((0.36,0.44),(0.64,0.44))],
            done: false
        ),
        LessonStep(
            instruction: "Your butterfly is ready! 🎉",
            action: .fold,
            faces: [
                f([(0.485,0.34),(0.515,0.34),(0.515,0.74),(0.485,0.74)], 0.30),
                f([(0.5,0.36),(0.10,0.14),(0.14,0.48)]),
                f([(0.5,0.36),(0.90,0.14),(0.86,0.48)], 0.10),
                f([(0.5,0.52),(0.18,0.54),(0.32,0.82)], 0.10),
                f([(0.5,0.52),(0.82,0.54),(0.68,0.82)])
            ],
            creases: [],
            arrows: [],
            done: true
        )
    ]
}

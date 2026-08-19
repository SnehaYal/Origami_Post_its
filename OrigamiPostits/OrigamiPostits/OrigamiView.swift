import SwiftUI
import Combine

// MARK: - The desktop origami "pet"
//
// Shows the drawn origami (tinted with the note's color), settles when it lands,
// and every 180–360 seconds plays a species-specific idle animation:
//   • butterfly flaps its wings   • swan bobs its head
//   • pinwheel spins              • sailboat sways
// Two-finger / right-click for change color / delete (with a dissipate send-off).

struct OrigamiView: View {
    @ObservedObject var origami: Origami
    var onDelete: () -> Void
    var onChangeColor: () -> Void

    @State private var rot: Double = 0       // rotation (spin / sway / settle)
    @State private var flapX: CGFloat = 1    // horizontal scale (butterfly flap)
    @State private var bobY: CGFloat = 0     // vertical offset (swan head bob)

    private var idleAnchor: UnitPoint { origami.type == .sailboat ? .bottom : .center }

    var body: some View {
        OrigamiGraphic(type: origami.type, color: origami.colorName)
            .frame(width: 84, height: 84)
            .scaleEffect(x: flapX, y: 1.0, anchor: .center)
            .rotationEffect(.degrees(rot), anchor: idleAnchor)
            .offset(y: bobY)
            .shadow(color: .black.opacity(0.22), radius: 5, x: 0, y: 3)
            .frame(width: 110, height: 110)
            .contentShape(Rectangle())
            .contextMenu {
                Button("Change color") { onChangeColor() }
                Button("Delete", role: .destructive) { onDelete() }
            }
            .onAppear {
                settle()
                scheduleIdle()
            }
    }

    /// A little landing bounce when the origami first appears (the reward beat).
    private func settle() {
        rot = -10
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) { rot = 0 }
    }

    /// Schedule the next idle animation 180–360 seconds out.
    /// TIP: to see it during testing, temporarily change the range to 4...6.
    private func scheduleIdle() {
        let delay = Double.random(in: 180...360)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            playIdle()
            scheduleIdle()
        }
    }

    private func playIdle() {
        switch origami.type {
        case .pinwheel:
            // Spin a half turn.
            withAnimation(.easeInOut(duration: 1.2)) { rot += 180 }

        case .butterfly:
            // Flap the wings by squashing horizontally a few times.
            withAnimation(.easeInOut(duration: 0.22).repeatCount(6, autoreverses: true)) { flapX = 0.5 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.2)) { flapX = 1.0 }
            }

        case .swan:
            // Bob the head up and down.
            withAnimation(.easeInOut(duration: 0.35).repeatCount(4, autoreverses: true)) { bobY = -6 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.2)) { bobY = 0 }
            }

        case .sailboat:
            // Rock gently, as if on water.
            withAnimation(.easeInOut(duration: 0.9).repeatCount(4, autoreverses: true)) { rot = 6 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.7) {
                withAnimation(.easeInOut(duration: 0.5)) { rot = 0 }
            }
        }
    }
}

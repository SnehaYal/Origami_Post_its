import SwiftUI
import Combine

// MARK: - The desktop origami "pet"
//
// A colored paper diamond (carries the note's color) with a placeholder emoji.
// It settles when it lands, wiggles gently every few minutes, and offers a
// two-finger / right-click menu to change color or delete.

struct OrigamiView: View {
    @ObservedObject var origami: Origami
    var onDelete: () -> Void
    var onChangeColor: () -> Void

    @State private var tilt: Double = 0

    var body: some View {
        ZStack {
            // Folded-paper placeholder: a tinted diamond so the note's color shows.
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(origami.colorName.color)
                .frame(width: 70, height: 70)
                .rotationEffect(.degrees(45))
                .shadow(color: .black.opacity(0.22), radius: 5, x: 0, y: 3)

            Text(origami.type.emoji)
                .font(.system(size: 44))
        }
        .rotationEffect(.degrees(tilt))
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
        tilt = -12
        withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) { tilt = 0 }
    }

    /// Idle "pet" life: a gentle wiggle every 180–360 seconds.
    /// TIP: to see it during testing, temporarily change the range to 4...6.
    private func scheduleIdle() {
        let delay = Double.random(in: 180...360)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            wiggle()
            scheduleIdle()
        }
    }

    private func wiggle() {
        withAnimation(.easeInOut(duration: 0.25)) { tilt = 8 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeInOut(duration: 0.25)) { tilt = -6 }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                withAnimation(.easeInOut(duration: 0.3)) { tilt = 0 }
            }
        }
    }
}

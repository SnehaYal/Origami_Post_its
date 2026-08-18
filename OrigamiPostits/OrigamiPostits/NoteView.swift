import SwiftUI
import Combine

// MARK: - The sticky note UI
//
// Color dots + close along the top, a free-text line, then the to-do checklist
// and an "add to-do" field. Ticking the last item prints a "ready to fold" note
// to the Xcode console — that's the hook where Phase 1's fold pop-up will go.

struct NoteView: View {
    @ObservedObject var note: StickyNote
    var onClose: () -> Void
    var onFold: () -> Void
    var onTuck: () -> Void

    @State private var newItemText: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Header: color swatches + close
            HStack(spacing: 6) {
                ForEach(NoteColor.allCases) { swatch in
                    Circle()
                        .fill(swatch.color)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle().stroke(
                                Color.black.opacity(note.colorName == swatch ? 0.55 : 0.15),
                                lineWidth: note.colorName == swatch ? 1.5 : 1
                            )
                        )
                        .onTapGesture { note.colorName = swatch }
                }
                Spacer()
                // Tuck this note away to the left-edge tray.
                Button(action: onTuck) {
                    Image(systemName: "tray.and.arrow.down")
                        .foregroundColor(.black.opacity(0.4))
                }
                .buttonStyle(.plain)
                .help("Tuck this note away to the side")

                // Fold into an origami (available any time, for testing/whenever).
                Button(action: onFold) {
                    Image(systemName: "wand.and.stars")
                        .foregroundColor(.black.opacity(0.4))
                }
                .buttonStyle(.plain)
                .help("Fold this note into an origami")

                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.black.opacity(0.35))
                }
                .buttonStyle(.plain)
            }

            // Free text
            TextField("Jot a thought…", text: $note.text, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .lineLimit(1...3)

            Divider().opacity(0.25)

            // Checklist
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach($note.items) { $item in
                        HStack(spacing: 6) {
                            Button {
                                item.isDone.toggle()
                                checkAllDone()
                            } label: {
                                Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(.black.opacity(0.55))
                            }
                            .buttonStyle(.plain)

                            Text(item.text)
                                .strikethrough(item.isDone, color: .black.opacity(0.4))
                                .foregroundColor(.black.opacity(item.isDone ? 0.4 : 0.85))
                                .font(.system(size: 13, design: .rounded))
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity)

            // Nudge: appears once every to-do is checked.
            if note.isReadyToFold {
                Button(action: onFold) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                        Text("Fold this note")
                    }
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.black.opacity(0.8))
                    .padding(.vertical, 7)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.white.opacity(0.5))
                    )
                }
                .buttonStyle(.plain)
            }

            // Add a new to-do
            HStack(spacing: 6) {
                Image(systemName: "plus")
                    .foregroundColor(.black.opacity(0.4))
                TextField("Add to-do…", text: $newItemText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13, design: .rounded))
                    .onSubmit(addItem)
            }
        }
        .padding(12)
        .frame(minWidth: 200, minHeight: 200)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(note.colorName.color)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        )
        .foregroundColor(.black)
    }

    private func addItem() {
        let trimmed = newItemText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        note.items.append(ChecklistItem(text: trimmed))
        newItemText = ""
    }

    private func checkAllDone() {
        let allDone = !note.items.isEmpty && note.items.allSatisfy { $0.isDone }
        withAnimation(.easeInOut(duration: 0.2)) {
            note.isReadyToFold = allDone
        }
        if allDone {
            print("✅ All items done — this note is ready to fold!")
        }
    }
}

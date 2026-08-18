import SwiftUI
import AppKit

// MARK: - App entry point
//
// A menu-bar (agent) app: no Dock icon, just a small note icon in the menu bar.
// Click it to make a new sticky note. One note is opened automatically on launch
// so you see something right away.

@main
struct OrigamiPostitsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Origami Post-its", systemImage: "note.text") {
            Button("New Note") { NoteManager.shared.newNote() }
                .keyboardShortcut("n")
            Divider()
            Button("Quit Origami Post-its") { NSApplication.shared.terminate(nil) }
                .keyboardShortcut("q")
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // .accessory = menu-bar app with no Dock icon (the "desktop pet" feel).
        NSApp.setActivationPolicy(.accessory)
        // Open one note on launch so there's something on screen to try.
        NoteManager.shared.newNote()
    }
}

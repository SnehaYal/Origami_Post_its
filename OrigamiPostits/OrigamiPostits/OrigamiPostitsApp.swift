import SwiftUI
import AppKit

// MARK: - App entry point
//
// A menu-bar (agent) app: no Dock icon, just a small note icon in the menu bar.
// Notes and origamis are restored from disk on launch and saved on quit.

@main
struct OrigamiPostitsApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        MenuBarExtra("Origami Post-its", systemImage: "note.text") {
            Button("New Note") { NoteManager.shared.newNote() }
                .keyboardShortcut("n")
            Divider()
            Button("Tuck All Away") { NoteManager.shared.tuckAll() }
            Button("Bring All Back") { NoteManager.shared.bringAll() }
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
        // Restore saved origamis and notes.
        OrigamiManager.shared.load()
        NoteManager.shared.load()
    }

    func applicationWillTerminate(_ notification: Notification) {
        NoteManager.shared.saveNow()
        OrigamiManager.shared.saveNow()
    }
}

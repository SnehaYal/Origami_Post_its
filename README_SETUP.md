# Origami Post-its — Phase 0 setup (floating sticky note)

This is the first buildable piece: a **floating, draggable, transparent sticky note**
that lives on your desktop, with a color picker and a checkable to-do list.
It's a menu-bar app (a small note icon in the top-right menu bar, no Dock icon).

You run this in **Xcode on your Mac**. It takes about 5 minutes.

## What you need
- A Mac with **Xcode** (free from the Mac App Store).
- macOS 13 (Ventura) or newer to run it.

## Steps

1. **Open Xcode → File → New → Project…**
2. Choose **macOS → App**, click Next.
3. Fill in:
   - Product Name: **OrigamiPostits**
   - Interface: **SwiftUI**
   - Language: **Swift**
   - (Uncheck "Use Core Data" and tests — not needed.)
   Click Next and save it somewhere.
4. In the new project, set the minimum macOS version:
   - Click the blue **OrigamiPostits** project at the top of the file list → **General** tab
     → under **Minimum Deployments**, set **macOS 13.0**.
5. **Swap in these files:**
   - In the file list, find the auto-created **`OrigamiPostitsApp.swift`** and the
     **`ContentView.swift`**.
   - **Delete `ContentView.swift`** (right-click → Delete → Move to Trash).
   - **Replace the contents of `OrigamiPostitsApp.swift`** with the file of the same
     name from this folder (open both, copy–paste over it). *(If you named your project
     something other than "OrigamiPostits", keep your file's name but paste in my code.)*
   - **Drag the other four files** into the project (into the same yellow folder):
     `NoteModels.swift`, `FloatingPanel.swift`, `NoteManager.swift`, `NoteView.swift`.
     When prompted, check **"Copy items if needed"** and make sure your app target is ticked.
6. Press **▶ Run** (or Cmd+R).

## What you should see
- A **note icon appears in the menu bar** (top-right of the screen).
- A **yellow sticky note floats on screen**. You can:
  - **Drag it anywhere** by grabbing an empty part of the note.
  - Click a **color dot** to recolor it.
  - Type a thought in the top line.
  - Type in **"Add to-do…"** and press Return to add checklist items.
  - **Tick items off.** When *every* item is checked, look at the Xcode console
    (bottom of the window) — you'll see **"✅ All items done — this note is ready to
    fold!"**. That log is the exact spot where the next phase's "What do you want to
    make?" fold pop-up will hook in.
  - Click the **✕** to close a note.
- Use the **menu-bar icon → New Note** (or Cmd+N) to add as many notes as you like.

## Notes / known Phase-0 limits (on purpose)
- Notes are **not saved yet** — closing the app clears them. Persistence comes next.
- No stacking/search yet — that's a later phase.
- The note floats *above* other windows for now so it's easy to test; we'll tune the
  exact "desktop layer" behavior later.

## If something's off
- **Can't type in a field?** Click the note once first to focus it, then the field.
- **Build errors about `MenuBarExtra` or `axis:`?** Your deployment target is below
  macOS 13 — set it to 13.0 (step 4).
- Tell me the exact error text and I'll fix the source.

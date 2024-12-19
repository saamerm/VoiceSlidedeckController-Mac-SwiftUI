//
//  VoiceSlidedeckControllerApp.swift
//  VoiceSlidedeckController
//
//  Created by Saamer Mansoor on 12/12/24.
//

import SwiftUI
final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isOpaque = false
//            window.backgroundColor = NSColor.clear
            window.backgroundColor = NSColor.secondarySystemBackground

//            window.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)?.isEnabled = false
//            self.view.window?.titleVisibility = .hidden
//            self.view.window?.titlebarAppearsTransparent = true
//            
          window.styleMask.insert(.fullSizeContentView)
            
            window.styleMask.remove(.closable)
            window.styleMask.insert(.borderless)
            window.styleMask.remove(.fullScreen)
            window.styleMask.remove(.miniaturizable)
            window.styleMask.remove(.resizable)
            
            //self.view.window?.isMovable = false


        }
    }
}

@main
struct VoiceSlidedeckControllerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("CurrentMenubarNumber") var currentMenubarNumber: String = "0"
    @AppStorage("IsListening") var isListening = false

    var body: some Scene {
        WindowGroup {
//            ContentView()
            SlideChangerView()
//            DesignedHomeView()
        }
        MenuBarExtra(currentMenubarNumber, systemImage: "\(currentMenubarNumber)." + (isListening ? "square.fill" : "circle")) {
            // 3
            Button(isListening ? "Stop" : "Start") {
                isListening = !isListening
            }.disabled(true)
            Divider()

            Button("Quit") {

                NSApplication.shared.terminate(nil)

            }.keyboardShortcut("q")
        }

//        .windowStyle(.hiddenTitleBar)
//        .windowStyle(HiddenTitleBarWindowStyle())
        .commands {
            CommandGroup(replacing: .newItem) {} // Disable unnecessary UI commands
        }
        
    }
}

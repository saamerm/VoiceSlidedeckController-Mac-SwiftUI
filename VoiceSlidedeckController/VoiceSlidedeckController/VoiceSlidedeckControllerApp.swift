//
//  VoiceSlidedeckControllerApp.swift
//  VoiceSlidedeckController
//
//  Created by Saamer Mansoor on 12/12/24.
//

import SwiftUI

@main
struct VoiceSlidedeckControllerApp: App {
    var body: some Scene {
        WindowGroup {
//            ContentView()
            SlideChangerView()
        }
        .commands {
            CommandGroup(replacing: .newItem) {} // Disable unnecessary UI commands
        }
    }
}

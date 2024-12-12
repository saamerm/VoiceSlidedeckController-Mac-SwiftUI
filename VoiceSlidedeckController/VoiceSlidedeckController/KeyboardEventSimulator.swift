//
//  Untitled.swift
//  VoiceSlidedeckController
//
//  Created by Saamer Mansoor on 12/12/24.
//

import Cocoa

func simulateKeyPress(key: CGKeyCode) {
    let source = CGEventSource(stateID: .combinedSessionState)
    let keyDown = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: true)
    let keyUp = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: false)
    
    keyDown?.post(tap: .cghidEventTap)
    keyUp?.post(tap: .cghidEventTap)
}

extension CGKeyCode {
    static let rightArrow: CGKeyCode = 124 // Key code for the right arrow key
    static let leftArrow: CGKeyCode = 123 // Key code for the left arrow key
    // 126 is up, 125 is up
}

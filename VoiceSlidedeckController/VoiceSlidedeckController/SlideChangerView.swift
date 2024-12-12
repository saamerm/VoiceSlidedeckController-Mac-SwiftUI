//
//  SlideChangerView.swift
//  VoiceSlidedeckController
//
//  Created by Saamer Mansoor on 12/12/24.
//

import Foundation
import SwiftUI
import Speech

struct SlideChangerView: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    var body: some View {
        VStack {
            Text("Speech Recognition App")
                .font(.headline)
            Text(speechRecognizer.transcript)
                .padding()
            Button(action: {
                speechRecognizer.startListening()
            }) {
                Text("Start Listening")
            }
            .disabled(speechRecognizer.isListening)
            
            Button(action: {
                speechRecognizer.stopListening()
            }) {
                Text("Stop Listening")
            }
            .disabled(!speechRecognizer.isListening)
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
    }
}

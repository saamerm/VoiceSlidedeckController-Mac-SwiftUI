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
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var transcript: String = ""
    @AppStorage("NextSlide") var nextSlide: String = ""
    @AppStorage("PreviousSlide") var previousSlide: String = ""
    @State var isListening: Bool = false
    @State var shouldChange = true
    private var recognizer: SFSpeechRecognizer?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    
    init() {
        var locale = Locale(identifier: "en-US")
        recognizer = SFSpeechRecognizer(locale: locale)
    }
//    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        VStack {
            Text("Slide Deck Automator")
                .font(.headline)
            Text("Transcript")
            Text(transcript)
                .padding()
            Button(action: {
                startListening()
            }) {
                Text("Start Listening")
            }
            .disabled(isListening)
            
            Button(action: {
                stopListening()
            }) {
                Text("Stop Listening")
            }
            .disabled(!isListening)
            Text("Words to accept for going to the next slide")
            TextField("Comma separated. Eg: 'next, next slide, right, ...'", text: $nextSlide)
            Text("Words to accept for going to the previous slide")
            TextField("Comma separated. Eg: 'previous, previous slide, left, ...'", text: $previousSlide)
        }
        .padding()
        .frame(minWidth: 300, minHeight: 200)
        .onReceive(timer) { input in
            shouldChange = true
        }
    }
    
    func startListening() {
        guard !isListening else { return }
        isListening = true
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                self.startRecognition()
            } else {
                DispatchQueue.main.async {
                    self.transcript = "Speech recognition not authorized."
                    self.isListening = false
                }
            }
        }
    }
    
    private func startRecognition() {
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true // True makes it go twice
        recognitionRequest.requiresOnDeviceRecognition = true
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            DispatchQueue.main.async {
                self.transcript = "Audio engine couldn't start."
                self.isListening = false
            }
        }
        recognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
                if result.speechRecognitionMetadata == nil {
                    self.handleSpeechCommand(self.transcript)
                }
            }
            guard let result = result else {
                print("There was an error transcribing that file")
                print("print \(error!.localizedDescription)")
                return
            }

            if error != nil {
                self.stopListening()
            }
        }
    }
    
    func stopListening() {
        isListening = false
        recognitionTask?.cancel()
//        recognitionTask = nil
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func handleSpeechCommand(_ command: String) {
        print(command)

        let normalizedCommand = command.lowercased()
        let rightCommandList = nextSlide.lowercased().split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let leftCommandList = previousSlide.lowercased().split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

        if rightCommandList.contains(where: { normalizedCommand.contains($0) }) {
            simulateKeyPress(key: .rightArrow)
        } else if leftCommandList.contains(where: { normalizedCommand.contains($0) }) {
            simulateKeyPress(key: .leftArrow)
        }
    }

    private func handleSpeechCommandOld(_ command: String) {
        print(command)
        var rightCommands = "next, next slide, right"
        if command.lowercased().contains("right") {
            simulateKeyPress(key: .rightArrow)
        } else if command.lowercased().contains("left") {
            simulateKeyPress(key: .leftArrow)
        }
    }
}

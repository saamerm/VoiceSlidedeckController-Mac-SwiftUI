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
    @State var numberOfLeftMatches = 0
    @State var numberOfRightMatches = 0
    init() {
        var locale = Locale(identifier: "en-US")
        recognizer = SFSpeechRecognizer(locale: locale)
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Slide Deck Automator")
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(.primary)
                .padding(.bottom, 10)
            Spacer()
            VStack(alignment: .leading, spacing: 10) {
                Text("Live Transcript")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.secondary)

                ScrollView {
                    Text(transcript.isEmpty ? "Transcript will appear here..." : transcript)
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundColor(transcript.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(.secondarySystemFill))
                        .cornerRadius(8)
                }
                .frame(height: 100)
            }
            if !AXIsProcessTrusted(){
                Text("Make sure System Preferences > Security & Privacy > Privacy > Accessibility is enabled")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(.red)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(alignment: .leading)
            }
            HStack(spacing: 20) {
                if !isListening{
                    Button(action: startListening) {
                        Text("Start Listening")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isListening ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(isListening)
                } else {
                    Button(action: stopListening) {
                        Text("Stop Listening")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isListening ? Color.red : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isListening)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Commands for Next Slide")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.secondary)

                TextField("Comma-separated commands (e.g., 'next, next slide, right')", text: $nextSlide)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 10)

                Text("Commands for Previous Slide")
                    .font(.system(size: 18, weight: .semibold, design: .default))
                    .foregroundColor(.secondary)

                TextField("Comma-separated commands (e.g., 'previous, previous slide, left')", text: $previousSlide)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            Spacer()
        }
        .padding()
        .background(Color(.secondarySystemFill))
        .frame(minWidth: 400, minHeight: 500)
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
                } else {
                    numberOfLeftMatches = 0
                    numberOfRightMatches = 0
                }
            }
            guard let result = result else {
                print("There was an error transcribing that file")
                print("print \(error!.localizedDescription)")
                self.stopListening()
                return
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
        let normalizedCommand = command.lowercased()
        let rightCommandList = nextSlide.lowercased().split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let leftCommandList = previousSlide.lowercased().split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let wordsInCommand = normalizedCommand.split(separator: " ").map { $0.lowercased() }
        let rightMatchesCount = wordsInCommand.filter { rightCommandList.contains($0) }.count
        let leftMatchesCount = wordsInCommand.filter { leftCommandList.contains($0) }.count

        if rightMatchesCount > 0 && rightMatchesCount > numberOfRightMatches{
            print("Right matches: \(rightMatchesCount)")
            simulateKeyPress(key: .rightArrow)
            numberOfRightMatches = numberOfRightMatches + 1
        } else if leftMatchesCount > 0  && leftMatchesCount > numberOfLeftMatches {
            print("Left matches: \(leftMatchesCount)")
            simulateKeyPress(key: .leftArrow)
            numberOfLeftMatches = numberOfLeftMatches + 1
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

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
    @State var recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    @State var transcript: String = ""
    @State var previouslyRecognizedTranscript = ""
    @State var completeTranscript = ""
    @State var currentSlideIndex = 1 // Start from 1st slide
    @AppStorage("NextSlide") var nextSlide: String = "next, next slide, right"
    @AppStorage("PreviousSlide") var previousSlide: String = ""
    @AppStorage("SlideNames") var slideNames: String = "home, financials, thank you"
    @AppStorage("IsListening") var isListening: Bool = false
    @AppStorage("CurrentMenubarNumber") var currentMenubarNumber: String = "1"
    @State var shouldChange = true
    @State var speechSecondsTimer = 0
    private var recognizer: SFSpeechRecognizer?
    @State var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    @State var numberOfLeftMatches = 0
    @State var numberOfRightMatches = 0
    @State var numberOfEmailTranscripts = 0
    @State var commandCounts: [String: Int] = [:] // To track command counts
    @State var machine = "" // To track command counts

    init() {
        // Locale(identifier: "en-US")
        recognizer = SFSpeechRecognizer(locale: Locale.current)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Presentation Whisperer")
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .padding(.bottom, 5)
                Text("Use this tool to automatically switch slides based on your speech. If you have MacOS 15.1 or later, you can also use the summary functionality.")
                    .font(.system(size: 12, design: .default))
                    .padding(.bottom, 10)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Live Transcript")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(.secondary)
                    
                    ScrollView {
                        Text(completeTranscript.isEmpty ? "Transcript will appear here..." : completeTranscript)
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(completeTranscript.isEmpty ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color("SecondarySystemFill"))
                            .cornerRadius(8)
                    }
                    .frame(height: 100)
                }
                if !AXIsProcessTrusted(){
                    HStack{
                        Text("Make sure System Preferences > Security & Privacy > Privacy > Accessibility is enabled")
                            .font(.system(size: 16, weight: .regular, design: .default))
                            .foregroundColor(.red)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(alignment: .leading)
                        Button("Open Settings") {
                            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
                        }
                    }
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
                        .padding(.bottom, 10)
                    
                    Text("Names of slides for 'Go to the {} slide' command")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .foregroundColor(.secondary)
                    
                    TextField("Order slides by names (e.g., 'home, financials, thank you')", text: $slideNames)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.bottom, 10)
                    HStack{
                        if #available(macOS 15.1, *)  {
                            if machine == "arm64" { // M1 mac
                                NavigationLink(destination: AppleIntelligenceView(transcript: $completeTranscript)) {
                                    Text("Summary")
                                        .font(.system(size: 16, weight: .medium, design: .default))
                                        .frame(maxWidth: .infinity)
                                        .padding()
        //                                .background(isListening ? Color.red : Color.gray)
        //                                .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
//                            else {
//                                Text(machine)
//                            }
                        }
                        else {
                            Text("Your Mac doesn't support summarization because it is not M1 or it is not running macOS 15.1 or later.")
                        }
                        Button(action: {
                            Task{
                                await uploadEmail(completeTranscript + "\n" + postSummaryBody, emailAddresses: emailAddresses, smsMinutes: smsMinutes)
                            }
                        }) {
                            Text("Email")
                                .font(.system(size: 16, weight: .medium, design: .default))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .cornerRadius(8)
                        }
                        NavigationLink(destination: EmailSettingsView()) {
                            Image(systemName: "gear")
                        }
                    }
                }
            }
            .padding()
            .background(Color("SecondarySystemFill"))
        }
        .frame(minWidth: 400, minHeight: 500)
        .onReceive(timer) { input in
            if isListening {
                speechSecondsTimer = speechSecondsTimer + 1
                currentMenubarNumber = String(speechSecondsTimer / 60)
            }
            shouldChange = true
        }
        .onAppear(){
            var systeminfo = utsname()
            uname(&systeminfo)
            machine = withUnsafeBytes(of: &systeminfo.machine) {bufPtr->String in
                let data = Data(bufPtr)
                if let lastIndex = data.lastIndex(where: {$0 != 0}) {
                    return String(data: data[0...lastIndex], encoding: .isoLatin1)!
                } else {
                    return String(data: data, encoding: .isoLatin1)!
                }
            }
            // This logic can't be in the init()
            stopListening()
        }
    }
    
    func startListening() {
        if #available(macOS 14.0, *) {
            AVAudioApplication.requestRecordPermission(completionHandler: {h in
//                print(AVAudioApplication.shared.isInputMuted)
            })
        } else {
            // Fallback on earlier versions
        }
        speechSecondsTimer = 0
        guard !isListening else { return }
        isListening = true
        SFSpeechRecognizer.requestAuthorization { authStatus in
            if authStatus == .authorized {
                self.startRecognition()
            } else {
                DispatchQueue.main.async {
                    self.transcript = "Speech recognition not authorized."
                    self.isListening = false
                    completeTranscript = transcript
                }
            }
        }
    }
    
    private func startRecognition() {
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true //
//        recognitionRequest.requiresOnDeviceRecognition = false // Setting to true, erases everything. Setting to false keeps it going. And then speechRecognitionMetadata always stays nil
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
                completeTranscript = transcript
            }
        }
        recognizer?.defaultTaskHint = .dictation

        guard let recognizer = SFSpeechRecognizer(locale: Locale.current) else {
            return
        }

        var recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { (result, error) in
            if let result = result {
                self.transcript = result.bestTranscription.formattedString
                if transcript.isEmpty {
                    completeTranscript = previouslyRecognizedTranscript
                } else {
                    completeTranscript = previouslyRecognizedTranscript + "\n" + transcript
                }
                if result.speechRecognitionMetadata == nil {
                    self.handleSpeechCommand(self.transcript)
                } else {
                    previouslyRecognizedTranscript = completeTranscript
                    numberOfLeftMatches = 0
                    numberOfRightMatches = 0
                    numberOfEmailTranscripts = 0
                    let slideList = slideNames.lowercased().split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    commandCounts = slideList.reduce(into: [:]) { dict, slide in
                        dict[slide] = 0
                    }
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
        recognitionTask?.finish()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func handleSpeechCommand(_ command: String) {
        let normalizedCommand = command.lowercased()
        let rightCommandList = nextSlide.lowercased().split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let leftCommandList = previousSlide.lowercased().split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let goToCommandList = slideNames.lowercased().split(separator: ",").map { "go to the " + $0.trimmingCharacters(in: .whitespacesAndNewlines) + " slide"}
        let wordsInCommand = normalizedCommand.split(separator: " ").map { $0.lowercased() }
        let rightMatchesCount = wordsInCommand.filter { rightCommandList.contains($0) }.count
        let leftMatchesCount = wordsInCommand.filter { leftCommandList.contains($0) }.count
        let emailTranscriptCount = normalizedCommand.components(separatedBy:"email the transcript").count - 1

//      for goToCommand in goToCommandList { // array.enumerated() gives pairs of and index and item, https://forums.developer.apple.com/forums/thread/118361
        for (index, goToCommand) in goToCommandList.enumerated() {
//            print(goToCommand)
//            print(normalizedCommand.components(separatedBy:goToCommand).count - 1)
            if (normalizedCommand.components(separatedBy:goToCommand).count - 1) > commandCounts[goToCommand, default: 0]  {
//                print(goToCommand)
//                print("Number of appearances: ")
//                print(normalizedCommand.components(separatedBy:goToCommand).count - 1)
//                print("Number of matches before: ")
//                print(commandCounts[goToCommand, default: 0])
//                print("Input: " + normalizedCommand)
//                print(goToCommand)
                print("MATCH")
//                print(-(currentSlideIndex - (index + 1))) // Index starts from 0 so we add 1 to it
//                print(currentSlideIndex - (index + 1)) // Index starts from 0 so we add 1 to it
//                print(currentSlideIndex - index)
                print(currentSlideIndex)
                print(index + 1)
                commandCounts[goToCommand, default: 0] += 1
                moveSlides(uneditableSteps: -(currentSlideIndex - (index + 1)))
            }
        }

        if rightMatchesCount > 0 && rightMatchesCount > numberOfRightMatches{
            print("Right matches: \(rightMatchesCount)")
            simulateKeyPress(key: .rightArrow)
            numberOfRightMatches = numberOfRightMatches + 1
            if (currentSlideIndex < goToCommandList.count){ // if it's less than the total/largest possible number
                currentSlideIndex = currentSlideIndex + 1
            }
        } else if leftMatchesCount > 0  && leftMatchesCount > numberOfLeftMatches {
            print("Left matches: \(leftMatchesCount)")
            simulateKeyPress(key: .leftArrow)
            numberOfLeftMatches = numberOfLeftMatches + 1
            if (currentSlideIndex > 1){ // if it's not less than the smallest possible number
                currentSlideIndex = currentSlideIndex - 1
            }
        } else if emailTranscriptCount > 0 && emailTranscriptCount > numberOfEmailTranscripts {
            print("MATCH Email send!")
            numberOfEmailTranscripts = numberOfEmailTranscripts + 1
            useVoiceToSendEmail()
        }
    }
    
    func useVoiceToSendEmail(){
//        print("Simulated email")
        Task{
            await uploadEmail(completeTranscript)
        }
    }

    func moveSlides(uneditableSteps: Int) {
        print(uneditableSteps)
        if uneditableSteps == 0 {
            print("return")
            return
        }
        var shouldMoveForward = false
        var steps = uneditableSteps // uneditableSteps is a let because it comes from the func param
        if steps > 0{
            for _ in 0..<steps {
                print("right")
                currentSlideIndex = currentSlideIndex + 1
                simulateKeyPress(key: .rightArrow)
            }
        } else {
            steps = steps * -1
            for _ in 0..<steps {
                print("left")
                currentSlideIndex = currentSlideIndex - 1
                simulateKeyPress(key: .leftArrow)
            }

        }
    }
}

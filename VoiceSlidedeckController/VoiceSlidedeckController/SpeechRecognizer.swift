import Foundation
import Speech

class SpeechRecognizer: ObservableObject {
    @Published var transcript: String = ""
    @Published var isListening: Bool = false
    
    private var recognizer: SFSpeechRecognizer?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var audioEngine = AVAudioEngine()
    
    init() {
        var locale = Locale(identifier: "en-US")
        recognizer = SFSpeechRecognizer(locale: locale)
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
        recognitionRequest.shouldReportPartialResults = false
        recognitionRequest.requiresOnDeviceRecognition = true
//        if #available(iOS 13, *) {
//            recognitionRequest.requiresOnDeviceRecognition = true
//        }
//        let audioSession = AVAudioSession.sharedInstance()
//        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
//        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

//        guard let inputNode = audioEngine.inputNode else {
//            DispatchQueue.main.async {
//                self.transcript = "Audio engine has no input node."
//                self.isListening = false
//            }
//            return
//        }
        
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
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                    self.handleSpeechCommand(self.transcript)
                }
            }
            guard let result = result else {
                print("There was an error transcribing that file")
                print("print \(error!.localizedDescription)")
                return
            }

            if (result.isFinal) {
                print(result.bestTranscription.formattedString)
            }

            if error != nil {
                self.stopListening()
            }
        }
    }
    
    func stopListening() {
        isListening = false
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    private func handleSpeechCommand(_ command: String) {
        print(command)
        if command.lowercased().contains("right") {
            simulateKeyPress(key: .rightArrow)
        } else if command.lowercased().contains("left") {
            simulateKeyPress(key: .leftArrow)
        }
    }
}

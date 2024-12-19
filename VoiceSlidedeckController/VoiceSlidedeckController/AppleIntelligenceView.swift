//
//  AppleIntelligenceView.swift
//  VoiceSlidedeckController
//
//  Created by Saamer Mansoor on 12/17/24.
//

import SwiftUI

struct AppleIntelligenceView: View {
    @Binding public var transcript : String
    @State public var summary : String = ""

    var body: some View {
        VStack {
//            Spacer()
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
            Text("In order to get a summary of the transcript you have to have Apple Intelligence enabled")
//            if (isWritingToolsActive){
//                Text("H")
//            }
            HStack{
                TextEditor(text: $transcript)
                    .onReceive(NotificationCenter.default.publisher(for: NSTextField.textDidChangeNotification)) { obj in
                        print(obj)
                        if let textField = obj.object as? NSTextField {
                            print(textField.stringValue)
                            textField.selectAll(self)
                        }
                    }
                Text("Select all the text in the editor -> Right Click -> Writing Tools -> Summarize")
            }
//            Button(action:{
//                Task{
//                    await uploadEmail(transcript)
//                }
//            }){
//                Text("Send Email")
//            }
        }
        .onAppear(){
            summary = transcript
        }
        .padding()
        .navigationTitle("Summarization")
    }
}

struct Form: Codable {
    let message: String
}

func uploadEmail(_ message: String) async{
    let encoded = try? JSONEncoder().encode(Form(message: message))
    var BaseUrl = "https://script.google.com/macros/s/AKfycbxnzX2869f93DMx3GrgLFsu976mNm1QMBTgfs8s5zmuZwyoKjtMN3UmfbC7bMKKDPj5/exec"
    let url = URL(string: BaseUrl)!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    do {
        var result = try await URLSession.shared.upload(for: request, from: encoded!)
        print(result.0)
        print(result.1)
    } catch {
        print("Checkout failed.")
    }
}



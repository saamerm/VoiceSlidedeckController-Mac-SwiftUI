//
//  AppleIntelligenceView.swift
//  VoiceSlidedeckController
//
//  Created by Saamer Mansoor on 12/17/24.
//

import SwiftUI

struct AppleIntelligenceView: View {
    @AppStorage("EmailAddresses") var emailAddresses = ""
    @AppStorage("SmsMinutes") var smsMinutes = 0
    @AppStorage("PostSummaryBody") var postSummaryBody = ""

    @Binding public var transcript : String
    @State public var summary : String = ""
    @State var tempMessage = ""
    var body: some View {
        VStack {
            Text("In order to get a summary of the transcript you have to have Apple Intelligence enabled")
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
            Button(action:{
                Task{
                    var status = await uploadEmail(transcript + "\n" + postSummaryBody, emailAddresses: emailAddresses, smsMinutes: smsMinutes)
                    withAnimation {
                        tempMessage = status
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        // 7.
                        withAnimation {
                            tempMessage = ""
                        }
                    }
                }
            }){
                Text("Send Email")
            }
            Text(tempMessage)
                .padding()
                .font(Font.custom("Avenir", size: 16))
                .foregroundColor(.secondary)
        }
        .onAppear(){
            summary = transcript
        }
        .padding()
        .navigationTitle("Summarization")
    }
}

struct Form: Codable {
    var message: String;
    var emailAddresses: String;
    var smsMinutes: Int;
}

struct ResponseModel : Codable {
    var Status : String
    var Reason : String
}

func uploadEmail(_ message: String, emailAddresses: String, smsMinutes: Int) async -> String {
    let encoded = try? JSONEncoder().encode(Form(message: message, emailAddresses: emailAddresses, smsMinutes: smsMinutes))
    var BaseUrl = "https://script.google.com/macros/s/AKfycbztaNvxxbxgBi2KdAuQ4K8_pfgPrIRsoEh-UO0q7sfc0DoI9jP07qbvc-oO33V2OFPh/exec"
    let url = URL(string: BaseUrl)!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    do {
        var result = try await URLSession.shared.upload(for: request, from: encoded!)
        print(result.0)
        print(result.1)
        let decodedResponse = try? JSONDecoder().decode(ResponseModel.self, from: result.0)
        return decodedResponse?.Reason ?? "Something went wrong"
    } catch {
        return "Something went wrong"
    }
}



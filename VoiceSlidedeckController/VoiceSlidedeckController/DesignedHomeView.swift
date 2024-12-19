//
//  DesignedHomeView.swift
//  VoiceSlidedeckController
//
//  Created by Saamer Mansoor on 12/13/24.
//

import SwiftUI

struct DesignedHomeView: View {
    @State private var transcript: String = ""
    @AppStorage("IsListening") var isListening: Bool = false
    @State private var nextSlide: String = "next, next slide, right"
    @State private var previousSlide: String = "previous, previous slide, left"

    var body: some View {
           VStack(spacing: 20) {
               Text("Slide Deck Automator")
                   .font(.system(size: 28, weight: .bold, design: .rounded))
                   .foregroundColor(Color.primary.opacity(0.98))
                   .padding(.bottom, 20)

               VStack(alignment: .leading, spacing: 15) {
                   Text("Live Transcript")
                       .font(.system(size: 20, weight: .semibold, design: .rounded))
                       .foregroundColor(.secondary)

                   ScrollView {
                       Text(transcript.isEmpty ? "Transcript will appear here..." : transcript)
                           .font(.system(size: 16, weight: .regular, design: .rounded))
                           .foregroundColor(transcript.isEmpty ? .gray : .primary)
                           .padding()
                           .background(
                               RoundedRectangle(cornerRadius: 10)
                                   .fill(Color(.secondarySystemBackground))
                                   .shadow(color: .gray.opacity(0.2), radius: 4, x: 2, y: 2)
                           )
                   }
                   .frame(height: 120)
               }

               HStack(spacing: 20) {
                   Button(action: startListening) {
                       Text("Start Listening")
                           .font(.system(size: 16, weight: .medium, design: .rounded))
                           .padding()
                           .frame(maxWidth: .infinity)
                           .background(isListening ? Color.gray : Color.green.opacity(0.7))
                           .foregroundColor(.white)
                           .cornerRadius(10)
                           .shadow(color: Color.green.opacity(0.4), radius: 4, x: 2, y: 2)
                   }
                   .disabled(isListening)

                   Button(action: stopListening) {
                       Text("Stop Listening")
                           .font(.system(size: 16, weight: .medium, design: .rounded))
                           .padding()
                           .frame(maxWidth: .infinity)
                           .background(isListening ? Color.red.opacity(0.7) : Color.gray)
                           .foregroundColor(.white)
                           .cornerRadius(10)
                           .shadow(color: Color.red.opacity(0.4), radius: 4, x: 2, y: 2)
                   }
                   .disabled(!isListening)
               }

               VStack(alignment: .leading, spacing: 15) {
                   Text("Commands for Next Slide")
                       .font(.system(size: 20, weight: .semibold, design: .rounded))
                       .foregroundColor(.secondary)

                   TextField("Comma-separated commands (e.g., 'next, next slide, right')", text: $nextSlide)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .padding()
                       .background(
                           RoundedRectangle(cornerRadius: 10)
                               .fill(Color(.secondarySystemBackground))
                               .shadow(color: .gray.opacity(0.2), radius: 4, x: 2, y: 2)
                       )

                   Text("Commands for Previous Slide")
                       .font(.system(size: 20, weight: .semibold, design: .rounded))
                       .foregroundColor(.secondary)

                   TextField("Comma-separated commands (e.g., 'previous, previous slide, left')", text: $previousSlide)
                       .textFieldStyle(RoundedBorderTextFieldStyle())
                       .padding()
                       .background(
                           RoundedRectangle(cornerRadius: 10)
                               .fill(Color(.secondarySystemBackground))
                               .shadow(color: .gray.opacity(0.2), radius: 4, x: 2, y: 2)
                       )
               }

               Spacer()
           }
           .padding()
           .background(
               RoundedRectangle(cornerRadius: 20)
                   .fill(LinearGradient(gradient: Gradient(colors: [Color(.systemGroupedBackground), Color(.secondarySystemBackground)]), startPoint: .top, endPoint: .bottom))
                   .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
           )
           .frame(minWidth: 400, minHeight: 600)
       }

    private func startListening() {
        isListening = true
        transcript = "Listening for commands..."
    }

    private func stopListening() {
        isListening = false
        transcript = ""
    }
}

struct DesignedHomeView_Previews: PreviewProvider {
    static var previews: some View {
        DesignedHomeView()
    }
}

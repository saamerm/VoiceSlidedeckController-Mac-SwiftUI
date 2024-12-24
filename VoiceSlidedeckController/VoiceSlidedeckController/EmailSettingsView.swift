//
//  EmailSettingsView.swift
//  VoiceSlidedeckController
//
//  Created by Saamer Mansoor on 12/19/24.
//
import SwiftUI

struct EmailSettingsView: View {
    
    @AppStorage("EmailAddresses") var emailAddresses = ""
    @AppStorage("SmsMinutes") var smsMinutes = 0
    @AppStorage("PostSummaryBody") var postSummaryBody = ""
    var body: some View {
        VStack {
            Text("List of email addresses to email:")
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundColor(.secondary)
            
            TextField("Comma-separated email address (e.g., 'a@a.com, b@b.com')", text: $emailAddresses)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
            
            Text("Enter the duration (in minutes) for which you want us to extract email addresses from SMS messages to your premium phone number to send the presentation summary (Premium Users only)")
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundColor(.secondary)
            
            TextField("Max 60 minutes", value: $smsMinutes, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
            Text("Enter any text here you would like to send in the email. Eg: presentation links, or social media handles")
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundColor(.secondary)
            TextEditorWithPlaceholder(text: $postSummaryBody, placeholder: "Here's the link to the presentation: ... \n \n Here's additional resources: ...")
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
            Text("Want to get rid of our footer on your subscriber emails? Or want to have the emails sent from your email? Contact us for premium access, email hi@deafassistant.com")
                .font(.system(size: 18, weight: .semibold, design: .default))
                .foregroundColor(.secondary)

        }
        .padding()
    }
}
            
struct TextEditorWithPlaceholder: View {
    @Binding var text: String
    var placeholder: String

     var body: some View {
         ZStack(alignment: .leading) {
             if text.isEmpty {
                VStack {
                     Text(placeholder)
                         .padding(.top, 10)
                         .padding(.leading, 6)
                         .opacity(0.8)
                     Spacer()
                 }
             }
             
             VStack {
                 TextEditor(text: $text)
                     .frame(minHeight: 150, maxHeight: 300)
                     .opacity(text.isEmpty ? 0.85 : 1)
                 Spacer()
             }
         }
     }
 }
            

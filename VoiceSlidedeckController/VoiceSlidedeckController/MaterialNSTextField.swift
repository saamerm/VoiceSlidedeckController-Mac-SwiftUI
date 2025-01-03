//
//  MaterialNSTextField.swift
//  VoiceSlidedeckController
//
//  Created by Saamer Mansoor on 12/18/24.
//

import SwiftUI

struct MaterialNSTextField: View {
    let placeholder: String
    @Binding var text: String
    @State var isFocus: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            BorderlessTextField(placeholder: placeholder, text: $text, isFocus: $isFocus)
                .frame(maxHeight: 40)
            Rectangle()
                .foregroundColor(isFocus ? .primary : .secondary)
                .frame(height: isFocus ? 2 : 1)
        }
    }
}

class FocusAwareTextView: NSTextView {
    var onFocusChange: (Bool) -> Void = { _ in }

    override func becomeFirstResponder() -> Bool {
        let textView = window?.fieldEditor(true, for: nil) as? NSTextView
        textView?.insertionPointColor = .blue
        if #available(macOS 15.0, *) {
            textView?.isWritingToolsActive
        } else {
            // Fallback on earlier versions
        }
        onFocusChange(true)
        return super.becomeFirstResponder()
    }
}

class FocusAwareTextField: NSTextField {
    var onFocusChange: (Bool) -> Void = { _ in }

    override func becomeFirstResponder() -> Bool {
        let textView = window?.fieldEditor(true, for: nil) as? NSTextView
        textView?.insertionPointColor = .blue
        onFocusChange(true)
        return super.becomeFirstResponder()
    }
}

struct BorderlessTextField: NSViewRepresentable {
    let placeholder: String
    @Binding var text: String
    @Binding var isFocus: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeNSView(context: Context) -> NSTextField {
        let textField = FocusAwareTextField()
        textField.placeholderAttributedString = NSAttributedString(
            string: placeholder,
            attributes: [
                NSAttributedString.Key.foregroundColor: Color.red
            ]
        )
        textField.isBordered = false
        textField.delegate = context.coordinator
        textField.backgroundColor = NSColor.clear
        textField.textColor = .cyan
//        textField.font = R.font.text
        textField.focusRingType = .none
        textField.onFocusChange = { isFocus in
            self.isFocus = isFocus
        }

        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        nsView.stringValue = text
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: BorderlessTextField

        init(_ textField: BorderlessTextField) {
            self.parent = textField
        }

        func controlTextDidEndEditing(_ obj: Notification) {
            self.parent.isFocus = false
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            self.parent.text = textField.stringValue
        }
    }
}

//
//  LegacyTextView.swift
//  SuffixArray
//
//  Created by artembolotov on 21.02.2023.
//

import SwiftUI
import Combine

struct LegacyTextView: UIViewRepresentable {
    @Binding public var isFirstResponder: Bool
    @Binding public var text: String

    public var configuration = { (view: UITextView) in }

    public init(text: Binding<String>, isFirstResponder: Binding<Bool>, configuration: @escaping (UITextView) -> () = { _ in }) {
        self.configuration = configuration
        self._text = text
        self._isFirstResponder = isFirstResponder
    }

    public func makeUIView(context: Context) -> UITextView {
        let view = UITextView()
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.delegate = context.coordinator
        return view
    }

    public func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        configuration(uiView)
        switch isFirstResponder {
        case true: uiView.becomeFirstResponder()
        case false: uiView.resignFirstResponder()
        }
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator($text, isFirstResponder: $isFirstResponder)
    }

    public class Coordinator: NSObject, UITextViewDelegate {
        var text: Binding<String>
        var isFirstResponder: Binding<Bool>

        init(_ text: Binding<String>, isFirstResponder: Binding<Bool>) {
            self.text = text
            self.isFirstResponder = isFirstResponder
        }
        
        @objc public func textViewDidChange(_ textView: UITextView) {
            self.text.wrappedValue = textView.text ?? ""
        }

        public func textViewDidBeginEditing(_ textView: UITextView) {
            self.isFirstResponder.wrappedValue = true
        }

        public func textViewDidEndEditing(_ textView: UITextView) {
            self.isFirstResponder.wrappedValue = false
        }
    }
}

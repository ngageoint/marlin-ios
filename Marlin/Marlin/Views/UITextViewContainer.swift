//
//  UITextViewContainer.swift
//  Marlin
//
//  Created by Daniel Barela on 5/12/23.
//

import Foundation
import SwiftUI

struct UITextViewContainer: UIViewRepresentable {
    let text: String
    
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UITextView {
        let view = UITextView()
        view.textContainer.widthTracksTextView = true
        view.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.autoresizingMask = [.flexibleHeight]
        view.textContainer.lineBreakMode = .byWordWrapping
        view.isScrollEnabled = false
        view.isEditable = false
        view.tintColor = UIColor(Color.primaryColor)
        view.font = UIFont.systemFont(ofSize: 14.0, weight: .regular)
        view.textColor = UIColor(Color.onSurfaceColor).withAlphaComponent(0.6)
        view.accessibilityLabel = "Text"
        return view
    }
    
    func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<Self>) {
        uiView.text = self.text
        if uiView.frame.size != .zero {
            uiView.isScrollEnabled = false
        }
    }
}

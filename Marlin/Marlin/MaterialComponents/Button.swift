//
//  Button.swift
//  Marlin
//
//  Created by Daniel Barela on 6/16/22.
//

import Foundation
import SwiftUI
import MaterialComponents

struct MaterialButton: UIViewRepresentable {
    let title: String?
    let image: UIImage?
    let action: () -> Void
    
    @EnvironmentObject var scheme: MarlinScheme
    
    init(title: String? = nil, image: UIImage? = nil, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.image = image
    }
    
    func makeUIView(context: Context) -> MDCButton {
        let button = MDCButton()
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        button.applyTextTheme(withScheme: scheme.containerScheme)
        return button
    }
    
    func updateUIView(_ uiView: MDCButton, context: Context) {
        if let title = title {
            uiView.setTitle(title, for: .normal)
        }
        
        if let image = image {
            uiView.setImage(image, for: .normal)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var button: MaterialButton
        
        init(_ button: MaterialButton) {
            self.button = button
        }
        
        @objc func buttonTapped() {
            button.action()
        }
    }
}

//
//  FloatingButton.swift
//  Marlin
//
//  Created by Daniel Barela on 6/30/22.
//

import Foundation
import SwiftUI
import MaterialComponents

struct MaterialFloatingButton: UIViewRepresentable {
    let title: String?
    @Binding var imageName: String
    @Binding var appearDisabled: Bool
    let action: () -> Void
    let shape: MDCFloatingButtonShape
        
    init(title: String? = nil, imageName: Binding<String>, appearDisabled: Binding<Bool> = .constant(false), shape: MDCFloatingButtonShape = .mini, action: @escaping () -> Void = {}) {
        self.title = title
        self.action = action
        self._imageName = imageName
        self.shape = shape
        self._appearDisabled = appearDisabled
    }
    
    func makeUIView(context: Context) -> MDCFloatingButton {
        let button = MDCFloatingButton(shape: self.shape)
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        button.rippleColor = UIColor(Color.primaryColorVariant)
        button.backgroundColor = UIColor(Color.surfaceColor)
        button.tintColor = UIColor(Color.primaryColorVariant)
        button.setImageTintColor(UIColor(Color.primaryColorVariant), for: .normal)
        return button
    }
    
    func updateUIView(_ uiView: MDCFloatingButton, context: Context) {
        if let title = title {
            uiView.setTitle(title, for: .normal)
        }
        
        uiView.setImage(UIImage(systemName: imageName), for: .normal)
        
        if appearDisabled {
            uiView.backgroundColor = UIColor(Color.disabledColor)
            uiView.tintColor = UIColor(Color.onSurfaceColor)
            uiView.setImageTintColor(UIColor(Color.onSurfaceColor), for: .normal)
        } else {
            uiView.backgroundColor = UIColor(Color.surfaceColor)
            uiView.tintColor = UIColor(Color.primaryColorVariant)
            uiView.setImageTintColor(UIColor(Color.primaryColorVariant), for: .normal)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var button: MaterialFloatingButton
        
        init(_ button: MaterialFloatingButton) {
            self.button = button
        }
        
        @objc func buttonTapped() {
            button.action()
        }
    }
}

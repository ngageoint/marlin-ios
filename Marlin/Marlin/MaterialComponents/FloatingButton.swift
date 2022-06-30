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
    
    @EnvironmentObject var scheme: MarlinScheme
    
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
        button.rippleColor = scheme.containerScheme.colorScheme.primaryColorVariant
        button.backgroundColor = scheme.containerScheme.colorScheme.surfaceColor;
        button.tintColor = scheme.containerScheme.colorScheme.primaryColorVariant;
        button.setImageTintColor(scheme.containerScheme.colorScheme.primaryColorVariant, for: .normal)
        return button
    }
    
    func updateUIView(_ uiView: MDCFloatingButton, context: Context) {
        if let title = title {
            uiView.setTitle(title, for: .normal)
        }
        
        uiView.setImage(UIImage(systemName: imageName), for: .normal)
        
        if appearDisabled {
            uiView.applySecondaryTheme(withScheme: scheme.disabledScheme)
        } else {
            uiView.backgroundColor = scheme.containerScheme.colorScheme.surfaceColor;
            uiView.tintColor = scheme.containerScheme.colorScheme.primaryColorVariant;
            uiView.setImageTintColor(scheme.containerScheme.colorScheme.primaryColorVariant, for: .normal)
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

//
//  DocumentPreview.swift
//  Marlin
//
//  Created by Daniel Barela on 11/1/22.
//

import Foundation
import UIKit
import SwiftUI

extension View {
    
    func documentPreview<Content: View>(
        previewUrl: Binding<URL?>,
        previewDate: Binding<Date>,
        @ViewBuilder content: @escaping () -> Content) -> some View {
        background {
            Color.clear
                .onChange(of: previewDate.wrappedValue) { show in
                    if let url = previewUrl.wrappedValue {
                        DocumentController().presentDocument(url: url)
                    }
                }
        }
    }
}

class DocumentController: NSObject, ObservableObject, UIDocumentInteractionControllerDelegate {

    func presentDocument(url: URL) {
        let controller = UIDocumentInteractionController()
        controller.delegate = self
        controller.url = url
        controller.presentPreview(animated: true)
    }
    
    func documentInteractionControllerViewControllerForPreview(_: UIDocumentInteractionController) -> UIViewController {
        return UIApplication.shared.keyWindow?.rootViewController ?? UIViewController()
    }
}

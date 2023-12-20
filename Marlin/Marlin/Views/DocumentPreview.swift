//
//  DocumentPreview.swift
//  Marlin
//
//  Created by Daniel Barela on 11/1/22.
//

import Foundation
import UIKit
import SwiftUI
import QuickLook

extension View {
    
    func documentPreview<Content: View>(
        previewUrl: Binding<URL?>,
        previewDate: Binding<Date>,
        @ViewBuilder content: @escaping () -> Content) -> some View {
        background {
            Color.clear
                .onChange(of: previewDate.wrappedValue) { _ in
                    if let url = previewUrl.wrappedValue {
                        DocumentController.shared.presentDocument(url: url)
                    }
                }
        }
    }
}

class DocumentController: NSObject, ObservableObject, UIDocumentInteractionControllerDelegate {

    public static let shared = DocumentController()
    var controller: UIDocumentInteractionController?
    var presentingViewController: UIViewController?
    
    override private init() {
        
    }
    
    func dismissPreview() {
        controller?.dismissPreview(animated: true)
        presentingViewController?.dismiss(animated: true, completion: {
            print("dismissed")
        })
    }
    
    func presentDocument(url: URL) {
        controller = UIDocumentInteractionController()
        controller?.delegate = self
        controller?.url = url
        controller?.presentPreview(animated: true)
    }
    
    func documentInteractionControllerViewControllerForPreview(_: UIDocumentInteractionController) -> UIViewController {
        presentingViewController = UIApplication.shared.keyWindow?.rootViewController ?? UIViewController()
        return presentingViewController!
    }
}

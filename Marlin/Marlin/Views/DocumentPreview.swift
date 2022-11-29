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
                .onChange(of: previewDate.wrappedValue) { show in
                    if let url = previewUrl.wrappedValue {
                        DocumentController().presentDocument(url: url)
                    }
                }
        }
    }
}

class DocumentController: NSObject, ObservableObject, UIDocumentInteractionControllerDelegate { //, QLPreviewControllerDataSource {

    func presentDocument(url: URL) {
        let controller = UIDocumentInteractionController()
        controller.delegate = self
        controller.url = url
        controller.presentPreview(animated: true)
    }
    
    func documentInteractionControllerViewControllerForPreview(_: UIDocumentInteractionController) -> UIViewController {
        return UIApplication.shared.keyWindow?.rootViewController ?? UIViewController()
    }
    
    // The QLPreviewController asks its delegate how many items it has:
//    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
//        return 1
//    }
//
//    // For each item (see method above), the QLPreviewController asks for
//    // a QLPreviewItem instance describing that item:
//    func previewController(
//        _ controller: QLPreviewController,
//        previewItemAt index: Int
//    ) -> QLPreviewItem {
    
//        guard let fileURL = Bundle.main.url(forResource: parent.name, withExtension: "usdz") else {
//            fatalError("Unable to load \(parent.name).reality from main bundle")
//        }
//
//        let item = ARQuickLookPreviewItem(fileAt: fileURL)
//        item.allowsContentScaling = parent.allowScaling
//        return item
//    }


}

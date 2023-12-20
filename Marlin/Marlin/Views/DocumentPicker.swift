//
//  DocumentPicker.swift
//  Marlin
//
//  Created by Daniel Barela on 3/28/23.
//

import Foundation

import SwiftUI
import UniformTypeIdentifiers

class DocumentPickerViewModel: ObservableObject {
    @Published var url: URL?
}

struct DocumentPicker: UIViewControllerRepresentable {
    @ObservedObject var model: DocumentPickerViewModel
    func makeUIViewController(context: Context) -> some UIViewController {
        let type = UTType("mil.nga.marlin.geoPackage") ?? .item
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [type])
        controller.allowsMultipleSelection = false
        controller.shouldShowFileExtensions = true
        controller.delegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    func makeCoordinator() -> DocumentPickerCoordinator {
        DocumentPickerCoordinator(model: model)
    }
    
}
class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    @ObservedObject var model: DocumentPickerViewModel
    
    init(model: DocumentPickerViewModel) {
        self.model = model
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        model.url = urls.first
    }
    
}

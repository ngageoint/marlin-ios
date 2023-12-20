//
//  ImportGeoPackageFile.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation
import SwiftUI

struct ImportGeoPackageFile: View {
    @ObservedObject var viewModel: MapLayerViewModel
    @State var chooseFile: Bool = false

    var body: some View {
        VStack(alignment: .leading) {
            Button("Import GeoPackage File") {
                chooseFile = true
            }
            .buttonStyle(MaterialButtonStyle(type: .contained))
        }
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $chooseFile, content: {
            DocumentPicker(model: viewModel.documentPickerViewModel)
        })
        .alert("Existing GeoPackage", isPresented: $viewModel.confirmFileOverwrite, actions: {
            Button("Import As New", role: .destructive) {
                if let geoPackageFileUrl = viewModel.fileUrl {
                    viewModel.fileChosen(url: geoPackageFileUrl, forceImport: true)
                }
            }
            Button("Use Existing", role: .cancel) {
                if let fileUrl = viewModel.fileUrl {
                    viewModel.useExistingFile(url: fileUrl)
                }
            }
            Button("Cancel") {
            }
        }, message: {
            if let url = viewModel.fileUrl {
                Text("""
                    An existing GeoPackage with the name \"**\(viewModel.importer.fileName(url: url))**\" \
                    has already been imported.  What would you like to do?
                """)
            } else {
                Text("An existing GeoPackage with the same name has been imported.  What would you like to do?")
            }
        })
        .background(Color.backgroundColor)
        .padding(16)
        
    }
}

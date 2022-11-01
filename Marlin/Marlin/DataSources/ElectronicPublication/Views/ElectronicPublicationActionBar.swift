//
//  ElectronicPublicationActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 10/26/22.
//

import SwiftUI

struct ElectronicPublicationActionBar: View {

    @ObservedObject var electronicPublication: ElectronicPublication
    
    init(electronicPublication: ElectronicPublication) {
        self.electronicPublication = electronicPublication
    }
    
    var body: some View {
        HStack(spacing:8) {
            Spacer()
            if electronicPublication.isDownloading {
                ProgressView(value: electronicPublication.downloadProgress)
                    .tint(Color.primaryColorVariant)
            }
            if electronicPublication.isDownloaded, electronicPublication.checkFileExists(), let url = URL(string: electronicPublication.savePath) {
                Button("Delete") {
                    electronicPublication.deleteFile()
                }
                VStack {
                    Button("Open") {
                        NotificationCenter.default.post(name: .DocumentPreview, object: url)
                    }
                }
            } else if !electronicPublication.isDownloading {
                Button("Download") {
                    electronicPublication.downloadFile()
                }
            } else {
                Button("Re-Download") {
                    electronicPublication.downloadFile()
                }
            }
        }
        .padding(.trailing, -8)
        .buttonStyle(MaterialButtonStyle())
    }
}

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
        HStack(spacing:0) {
            Spacer()
            BookmarkButton(viewModel: BookmarkViewModel(itemKey: electronicPublication.itemKey, dataSource: ElectronicPublication.key))
            if electronicPublication.isDownloading {
                if let error = electronicPublication.error {
                    Text(error)
                        .secondary()
                    Spacer()
                } else {
                    ProgressView(value: electronicPublication.downloadProgress)
                        .tint(Color.primaryColorVariant)
                }
            }
            if electronicPublication.isDownloaded, electronicPublication.checkFileExists(), let url = URL(string: electronicPublication.savePath) {
                Button(action: {
                    NotificationCenter.default.post(name: .DocumentPreview, object: url)
                }) {
                    Label(
                        title: {},
                        icon: { Image("preview")
                                .renderingMode(.template)
                                .foregroundColor(Color.primaryColorVariant)
                        })
                }
                .accessibilityElement()
                .accessibilityLabel("Open")
                
                Button(action: {
                    electronicPublication.deleteFile()
                }) {
                    Label(
                        title: {},
                        icon: { Image(systemName: "trash.fill")
                                .renderingMode(.template)
                                .foregroundColor(Color.primaryColorVariant)
                        })
                }
                .accessibilityElement()
                .accessibilityLabel("Delete")
            } else if !electronicPublication.isDownloading {
                Button(action: {
                    electronicPublication.downloadFile()
                }) {
                    Label(
                        title: {},
                        icon: { Image(systemName: "square.and.arrow.down")
                                .renderingMode(.template)
                                .foregroundColor(Color.primaryColorVariant)
                        })
                }
                .accessibilityElement()
                .accessibilityLabel("Download")
            } else {
                Button(action: {
                    electronicPublication.cancelDownload()
                }) {
                    Label(
                        title: {},
                        icon: { Image(systemName: "xmark.circle.fill")
                                .renderingMode(.template)
                                .foregroundColor(Color.primaryColorVariant)
                        })
                }
                .accessibilityElement()
                .accessibilityLabel("Cancel")
            }
        }
        .padding(.trailing, -8)
        .buttonStyle(MaterialButtonStyle())
    }
}

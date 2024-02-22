//
//  ElectronicPublicationActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 10/26/22.
//

import SwiftUI

struct ElectronicPublicationActionBar: View {
    @EnvironmentObject var repository: ElectronicPublicationRepository
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
    
    @ObservedObject var viewModel: ElectronicPublicationViewModel

    init(viewModel: ElectronicPublicationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        switch viewModel.electronicPublication {
        case nil:
            Color.clear
        case .some(let electronicPublication):
            HStack(spacing: 0) {
                Spacer()
                BookmarkButton(viewModel: bookmarkViewModel)
                if electronicPublication.isDownloading != true {
                    if let error = electronicPublication.error {
                        Text(error)
                            .secondary()
                        Spacer()
                    }
                }
                if electronicPublication.isDownloaded == true, viewModel.checkFileExists(),
                   let url = URL(string: electronicPublication.savePath) {
                    Button(
                        action: {
                            NotificationCenter.default.post(name: .DocumentPreview, object: url)
                        },
                        label: {
                            Label(
                                title: {},
                                icon: { Image("preview")
                                        .renderingMode(.template)
                                        .foregroundColor(Color.primaryColorVariant)
                                })
                        }
                    )
                    .accessibilityElement()
                    .accessibilityLabel("Open")

                    Button(
                        action: {
                            viewModel.deleteFile()
                        },
                        label: {
                            Label(
                                title: {},
                                icon: { Image(systemName: "trash.fill")
                                        .renderingMode(.template)
                                        .foregroundColor(Color.primaryColorVariant)
                                })
                        }
                    )
                    .accessibilityElement()
                    .accessibilityLabel("Delete")
                } else if (electronicPublication.isDownloading ?? false) == false {
                    Button(
                        action: {
                            viewModel.downloadFile()
                        },
                        label: {
                            Label(
                                title: {},
                                icon: { Image(systemName: "square.and.arrow.down")
                                        .renderingMode(.template)
                                        .foregroundColor(Color.primaryColorVariant)
                                })
                        }
                    )
                    .accessibilityElement()
                    .accessibilityLabel("Download")
                } else {
                    ProgressView(value: electronicPublication.downloadProgress)
                        .tint(Color.primaryColorVariant)
                    Button(
                        action: {
                            viewModel.cancelDownload()
                        },
                        label: {
                            Label(
                                title: {},
                                icon: { Image(systemName: "xmark.circle.fill")
                                        .renderingMode(.template)
                                        .foregroundColor(Color.primaryColorVariant)
                                })
                        }
                    )
                    .accessibilityElement()
                    .accessibilityLabel("Cancel")
                }
            }
            .padding(.trailing, -8)
            .buttonStyle(MaterialButtonStyle())
            .onAppear {
                bookmarkViewModel.repository = bookmarkRepository
                bookmarkViewModel.getBookmark(
                    itemKey: electronicPublication.itemKey,
                    dataSource: electronicPublication.key
                )
            }
        }
    }
}

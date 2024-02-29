//
//  PublicationActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 10/26/22.
//

import SwiftUI

struct PublicationActionBar: View {
    @EnvironmentObject var repository: PublicationRepository
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
    
    @ObservedObject var viewModel: PublicationViewModel

    init(viewModel: PublicationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        switch viewModel.publication {
        case nil:
            Color.clear
        case .some(let publication):
            HStack(spacing: 0) {
                Spacer()
                BookmarkButton(
                    action: Actions.Bookmark(
                        itemKey: publication.itemKey,
                        bookmarkViewModel: bookmarkViewModel
                    )
                )
                if publication.isDownloading != true {
                    if let error = publication.error {
                        Text(error)
                            .secondary()
                        Spacer()
                    }
                }
                if publication.isDownloaded == true, viewModel.checkFileExists(),
                   let url = URL(string: publication.savePath) {
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
                } else if (publication.isDownloading ?? false) == false {
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
                    ProgressView(value: publication.downloadProgress)
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
                    itemKey: publication.itemKey,
                    dataSource: publication.key
                )
            }
        }
    }
}

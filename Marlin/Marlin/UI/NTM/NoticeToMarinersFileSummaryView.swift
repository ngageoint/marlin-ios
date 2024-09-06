//
//  NoticeToMarinersSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/14/22.
//

import SwiftUI

struct NoticeToMarinersFileSummaryView: DataSourceSummaryView {
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
    @EnvironmentObject var router: MarlinRouter

    @State var odsEntryId: Int

    var showTitle: Bool = false
    
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false
    var showMoreDetails: Bool = false

    @StateObject var viewModel: NoticeToMarinersViewModel = NoticeToMarinersViewModel()

    var bcf: ByteCountFormatter {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        return bcf
    }
    
    var body: some View {
        switch viewModel.noticeToMariners {
        case nil:
            Color.clear.onAppear {
                viewModel.setupModel(odsEntryId: odsEntryId)
            }
        case .some(let noticeToMariners):
            VStack(alignment: .leading, spacing: 8) {
                Text("""
                    \(noticeToMariners.title ?? "")\
                    \(noticeToMariners.isFullPublication ? (" \(noticeToMariners.fileExtension ?? "")") : "")
                    """)
                .primary()
                Text("File Size: \(bcf.string(fromByteCount: Int64(noticeToMariners.fileSize ?? 0)))")
                    .secondary()
                if let uploadTime = noticeToMariners.uploadTime {
                    Text("Upload Time: \(uploadTime.formatted(date: .complete, time: .omitted))")
                        .overline()
                }
                HStack(spacing: 0) {
                    Spacer()
                    if noticeToMariners.isDownloading != true {
                        if let error = noticeToMariners.error {
                            Text(error)
                                .secondary()
                            Spacer()
                        }
                    }
                    if noticeToMariners.isDownloaded == true, viewModel.checkFileExists(),
                       let url = URL(string: noticeToMariners.savePath) {
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
                    } else if (noticeToMariners.isDownloading) == false {
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
                        ProgressView(value: noticeToMariners.downloadProgress)
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

            }
        }
    }
}

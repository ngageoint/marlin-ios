//
//  NoticeToMarinersSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/14/22.
//

import SwiftUI

struct NoticeToMarinersFileSummaryView: DataSourceSummaryView {
    var showTitle: Bool = false
    
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false
    @ObservedObject var noticeToMariners: NoticeToMariners
    var showMoreDetails: Bool = false
    
    var bcf: ByteCountFormatter {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
        return bcf
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(noticeToMariners.title ?? "")\(noticeToMariners.isFullPublication ? (" \(noticeToMariners.fileExtension ?? "")") : "")")
                .primary()
            Text("File Size: \(bcf.string(fromByteCount: noticeToMariners.fileSize))")
                .secondary()
            if let uploadTime = noticeToMariners.uploadTime {
                Text("Upload Time: \(uploadTime.formatted(date: .complete, time: .omitted))")
                    .overline()
            }
            HStack(spacing: 8) {
                Spacer()
                if noticeToMariners.isDownloading {
                    ProgressView(value: noticeToMariners.downloadProgress)
                        .tint(Color.primaryColorVariant)
                }
                if noticeToMariners.isDownloaded, noticeToMariners.checkFileExists(), let url = URL(string: noticeToMariners.savePath) {
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
                        noticeToMariners.deleteFile()
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
                } else if !noticeToMariners.isDownloading {
                    Button(action: {
                        noticeToMariners.downloadFile()
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
                        noticeToMariners.cancelDownload()
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
            .buttonStyle(MaterialButtonStyle(type: .text))
        }
        .frame(maxWidth: .infinity)
    }
}

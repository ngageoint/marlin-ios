//
//  NoticeToMarinersSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/14/22.
//

import SwiftUI

struct NoticeToMarinersSummaryView: View {
    
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
                Text("Upload Time: \(uploadTime.formatted())")
                    .overline()
            }
            HStack(spacing: 8) {
                Spacer()
                if noticeToMariners.isDownloading {
                    ProgressView(value: noticeToMariners.downloadProgress)
                        .tint(Color.primaryColorVariant)
                }
                if noticeToMariners.isDownloaded, noticeToMariners.checkFileExists(), let url = URL(string: noticeToMariners.savePath) {
                    Button("Delete") {
                        noticeToMariners.deleteFile()
                    }
                    VStack {
                        Button("Open") {
                            NotificationCenter.default.post(name: .DocumentPreview, object: url)
                        }
                    }
                } else if !noticeToMariners.isDownloading {
                    Link(destination: noticeToMariners.remoteLocation!, label: {
                        Text("Open In Browser")
                            .buttonStyle(MaterialButtonStyle(type: .text))
                    })
                    Button("Download") {
                        noticeToMariners.downloadFile()
                    }
                } else {
                    Button("Re-Download") {
                        noticeToMariners.downloadFile()
                    }
                }
            }
            .buttonStyle(MaterialButtonStyle(type: .text))
        }
        .frame(maxWidth: .infinity)
    }
}

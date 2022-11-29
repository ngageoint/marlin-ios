//
//  NoticeToMarinersSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/14/22.
//

import SwiftUI

struct NoticeToMarinersSummaryView: View {
    
    var noticeToMariners: NoticeToMariners
    var showMoreDetails: Bool = false
    
    let bcf = ByteCountFormatter()
    
    init(noticeToMariners: NoticeToMariners) {
        self.noticeToMariners = noticeToMariners
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(noticeToMariners.title ?? "") \(noticeToMariners.isFullPublication ? (noticeToMariners.fileExtension ?? "") : "")")
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

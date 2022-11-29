//
//  NoticeToMarinersDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/14/22.
//

import SwiftUI

struct NoticeToMarinersDetailView: View {
    
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
            Text("\(noticeToMariners.filenameBase ?? "")")
                .primary()
            Text("File Size: \(bcf.string(fromByteCount: noticeToMariners.fileSize))")
                .secondary()
            if let uploadTime = noticeToMariners.uploadTime {
                Text("Upload Time: \(uploadTime.formatted())")
                    .overline()
            }
            //            NoticeToMarinersAction(noticeToMariners: electronicPublication)
        }
    }
}

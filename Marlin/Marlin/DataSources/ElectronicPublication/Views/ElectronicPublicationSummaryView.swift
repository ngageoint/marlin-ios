//
//  ElectronicPublicationSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import SwiftUI

struct ElectronicPublicationSummaryView: View {
    
    var electronicPublication: ElectronicPublication
    var showMoreDetails: Bool = false
    
    let bcf = ByteCountFormatter()
    
    init(electronicPublication: ElectronicPublication, showMoreDetails: Bool = false) {
        self.electronicPublication = electronicPublication
        self.showMoreDetails = showMoreDetails
        bcf.allowedUnits = [.useAll]
        bcf.countStyle = .file
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(electronicPublication.sectionDisplayName ?? "")")
                .primary()
            Text("File Size: \(bcf.string(fromByteCount: electronicPublication.fileSize))")
                .secondary()
            if let uploadTime = electronicPublication.uploadTime {
                Text("Upload Time: \(uploadTime.formatted())")
                    .overline()
            }
            ElectronicPublicationActionBar(electronicPublication: electronicPublication)
        }
    }
}

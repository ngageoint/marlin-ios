//
//  ElectronicPublicationDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import SwiftUI

struct ElectronicPublicationDetailView: View {
    @EnvironmentObject var scheme: MarlinScheme
    @State var showSelectable: Bool = false
    
    var electronicPublication: ElectronicPublication
    
    init(electronicPublication: ElectronicPublication) {
        self.electronicPublication = electronicPublication
    }
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    if let uploadTime = electronicPublication.uploadTime {
                        Text(ElectronicPublication.dateFormatter.string(from: uploadTime))
                            .overline()
                    }
                    Text("\(electronicPublication.pubDownloadDisplayName ?? "")")
                        .primary()
                    Text(PublicationTypeEnum(rawValue: Int(electronicPublication.pubTypeId))?.description ?? "")
                        .lineLimit(8)
                        .secondary()
                }
                .padding(.all, 16)
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle("\(electronicPublication.sectionDisplayName ?? ElectronicPublication.fullDataSourceName)")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Metrics.shared.dataSourceDetail(dataSource: ElectronicPublication.self)
        }
    }
}

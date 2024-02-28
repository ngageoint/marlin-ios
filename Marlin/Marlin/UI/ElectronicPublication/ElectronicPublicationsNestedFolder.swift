//
//  ElectronicPublicationsNestedFolder.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/24.
//

import Foundation
import SwiftUI

struct ElectronicPublicationsNestedFolder: View {
    @EnvironmentObject var repository: ElectronicPublicationRepository
    @StateObject var viewModel: ElectronicPublicationsNestedFolderViewModel = 
        ElectronicPublicationsNestedFolderViewModel()
    var pubTypeId: Int

    var body: some View {
        List {
            ForEach(Array(viewModel.nestedFolders.keys), id: \.self) { key in
                if let group = viewModel.nestedFolders[key], !group.isEmpty {
                    NavigationLink(value: ElectronicPublicationRoute.publicationList(key: key, pubs: group)) {
                        HStack(spacing: 16) {
                            Image(systemName: "folder.fill")
                                .renderingMode(.template)
                                .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                            VStack(alignment: .leading) {
                                Text(key)
                                    .primary()
                                Text("\(group.count) files")
                                    .secondary()
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .accessibilityElement()
                        .accessibilityLabel(key)
                    }
                }
            }
        }
        .background(Color.backgroundColor)
        .listRowBackground(Color.surfaceColor)
        .listStyle(.plain)
        .navigationTitle((PublicationTypeEnum(rawValue: pubTypeId) ?? .unknown).description)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.repository = repository
            viewModel.pubTypeId = pubTypeId
            Metrics.shared.appRoute(["epubs", PublicationTypeEnum(rawValue: pubTypeId)?.description ?? "pubs"])
        }
    }
}

//
//  PublicationsNestedFolder.swift
//  Marlin
//
//  Created by Daniel Barela on 2/27/24.
//

import Foundation
import SwiftUI

struct PublicationsNestedFolder: View {
    @StateObject var viewModel: PublicationsNestedFolderViewModel =
        PublicationsNestedFolderViewModel()
    @EnvironmentObject var router: MarlinRouter
    var pubTypeId: Int

    var body: some View {
        List {
            ForEach(Array(viewModel.nestedFolders.keys), id: \.self) { key in
                if let group = viewModel.nestedFolders[key], !group.isEmpty {
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
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .accessibilityElement()
                    .accessibilityLabel(key)
                    .onTapGesture {
                        router.path.append(PublicationRoute.publicationList(key: key, pubs: group))
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
            viewModel.pubTypeId = pubTypeId
            Metrics.shared.appRoute(["epubs", PublicationTypeEnum(rawValue: pubTypeId)?.description ?? "pubs"])
        }
    }
}

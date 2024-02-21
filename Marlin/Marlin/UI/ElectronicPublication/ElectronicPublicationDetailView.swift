//
//  ElectronicPublicationDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import SwiftUI

struct ElectronicPublicationDetailView: View {    
    @EnvironmentObject var repository: ElectronicPublicationRepository
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()
    var s3Key: String
    @StateObject var viewModel: ElectronicPublicationViewModel = ElectronicPublicationViewModel()

    var body: some View {
        Group {
            switch viewModel.electronicPublication {
            case nil:
                Color.clear.onAppear {
                    viewModel.setupModel(repository: repository, s3Key: s3Key)
                }
            case .some(let electronicPublication):

                List {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(electronicPublication.itemTitle)
                                .padding(.all, 8)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .itemTitle()
                                .foregroundColor(Color.white)
                                .background(Color(uiColor: DataSources.epub.color))
                                .padding(.bottom, -8)
                            if let uploadTime = electronicPublication.uploadTime {
                                Text(DataSources.epub.dateFormatter.string(from: uploadTime))
                                    .overline()
                            }
                            Text("\(electronicPublication.pubDownloadDisplayName ?? "")")
                                .primary()
                            Text(PublicationTypeEnum(rawValue: Int(electronicPublication.pubTypeId ?? -1))?.description ?? "")
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
                .onAppear {
                    bookmarkViewModel.repository = bookmarkRepository
                    bookmarkViewModel.getBookmark(itemKey: electronicPublication.itemKey, dataSource: DataSources.epub.key)
                }
                .navigationTitle("\(electronicPublication.sectionDisplayName ?? DataSources.epub.fullName)")
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Metrics.shared.dataSourceDetail(dataSource: DataSources.epub)
        }
    }
}

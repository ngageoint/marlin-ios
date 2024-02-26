//
//  NoticeToMarinersFullNoticeView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/15/22.
//

import SwiftUI

struct NoticeToMarinersFullNoticeView: View {
    @EnvironmentObject var noticeToMarinersRepository: NoticeToMarinersRepository
    @State var noticeNumber: Int
    @StateObject var viewModel: NoticeToMarinersFullNoticeViewViewModel = NoticeToMarinersFullNoticeViewViewModel()

    private var gridColumns = Array(repeating: GridItem(.flexible()), count: 3)
    private var numColumns = 3

    init(noticeNumber: Int) {
        self.noticeNumber = noticeNumber
    }

    @ViewBuilder
    func sectionHeader() -> some View {
        if let pub = viewModel.notices.first {
            NoticeToMarinersSummaryView(noticeToMariners: NoticeToMarinersListModel(noticeToMarinersModel: pub))
                .showBookmarkNotes(true)
        }
    }

    var body: some View {
        List {
            Section("Notice") {
                sectionHeader()
                    .padding(.all, 16)
                    .card()
            }
            .dataSourceSection()
            graphicsView()
            Section("Files") {
                ForEach(viewModel.notices) { ntm in
                    if let odsEntryId = ntm.odsEntryId {
                        NoticeToMarinersFileSummaryView(odsEntryId: odsEntryId)
                            .padding(.all, 16)
                            .card()
                    }
                }
                .dataSourceSummaryItem()
            }
            .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle("Notice \(viewModel.noticeNumberString ?? "")")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.setupModel(noticeNumber: noticeNumber)
            viewModel.repository = noticeToMarinersRepository
            viewModel.getNotices(noticeNumber: noticeNumber)
            viewModel.loadGraphics()
            Metrics.shared.appRoute(["ntms", "detail"])
        }
    }
    
    @ViewBuilder
    func graphicsView() -> some View {
        ForEach(Array(viewModel.sortedGraphicKeys), id: \.self) { key in
            if let items = viewModel.graphics[key], !items.isEmpty {
                Section("\(items[0].graphicType ?? "Graphic")s") {
                    LazyVGrid(columns: gridColumns) {
                        ForEach(items) { item in
                            VStack {
                                AsyncImage(
                                    url: URL(string: item.graphicUrl)!,
                                    name: item.fileName ?? "image.png",
                                    placeholder: { Text("Loading ...").overline() },
                                    image: { Image(uiImage: $0).resizable() }
                                )
                                .aspectRatio(contentMode: .fit)
                                Text("\(item.graphicType ?? "Chart") \(item.chartNumber ?? "")").overline()
                            }
                        }
                    }
                    .padding(.all, 16)
                    .card()
                }
                .dataSourceSection()
            }
            
        }
        .dataSourceSection()
    }
}

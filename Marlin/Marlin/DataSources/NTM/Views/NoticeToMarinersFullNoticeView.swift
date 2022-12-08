//
//  NoticeToMarinersFullNoticeView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/15/22.
//

import SwiftUI

struct NoticeToMarinersFullNoticeView: View {
    @ObservedObject var viewModel: NoticeToMarinersFullNoticeViewViewModel

    @FetchRequest<NoticeToMariners>
    var noticeToMarinersPublications: FetchedResults<NoticeToMariners>
        
    private var gridColumns = Array(repeating: GridItem(.flexible()), count: 3)
    private var numColumns = 3
    
    init(noticeNumber: Int64? = nil, noticeNumberString: String? = nil) {
        let viewModel = NoticeToMarinersFullNoticeViewViewModel(noticeNumber: noticeNumber, noticeNumberString: noticeNumberString)
        self._noticeToMarinersPublications = viewModel.createFetchRequest()
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            graphicsView()
            Section("Files") {
                ForEach(noticeToMarinersPublications) { ntm in
                    NoticeToMarinersSummaryView(noticeToMariners: ntm)
                        .padding(.all, 16)
                        .card()
                }
                .dataSourceSummaryItem()
            }
            .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle("Notice \(viewModel.noticeNumberString ?? "")")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: viewModel.loadGraphics)
    }
    
    @ViewBuilder
    func graphicsView() -> some View {
        ForEach(Array(viewModel.sortedGraphicKeys), id: \.self) { key in
            if let items = viewModel.graphics[key] {
                if !items.isEmpty {
                    Section("\(items[0].graphicType ?? "Graphics")") {
                        LazyVGrid(columns: gridColumns) {
                            ForEach(items) { item in
                                VStack {
                                    AsyncImage(
                                        url: URL(string:item.graphicUrl)!,
                                        name: item.fileName ?? "image.png",
                                        placeholder: { Text("Loading ...").overline() },
                                        image: { Image(uiImage: $0).resizable() }
                                    )
                                    .aspectRatio(contentMode: .fit)
                                    Text("Chart \(item.chartNumber ?? "")").overline()
                                }
                            }
                        }
                    }
                    .padding(.all, 8)
                }
            }
            
        }
        .dataSourceSection()
    }
}

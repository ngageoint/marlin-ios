//
//  NoticeToMarinersView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/11/22.
//

import SwiftUI

struct NoticeToMarinersView: View {
    @StateObject var itemWrapper: ItemWrapper = ItemWrapper()

    var body: some View {
        List {
            NavigationLink {
                
                
                MSIListView<NoticeToMariners, AnyView>(focusedItem: itemWrapper, watchFocusedItem: false, filterPublisher: UserDefaults.standard.publisher(for: \.ntmFilter), sortPublisher: UserDefaults.standard.publisher(for: \.ntmSort), allowUserSort: false, allowUserFilter: false, sectionHeaderIsSubList: true) { section in
                    if let sectionInt = Int(section.name) {
                        return "Notice: \(Int(sectionInt / 100) % 1000)/\(sectionInt % 100)"
                    } else {
                        return "dunno"
                    }
                } content: { section in
//                    if let first = section.items.first {
                        AnyView(NoticeToMarinersFullNoticeView(noticeNumber: Int64(section.name)))
//                    }
//                    ScrollView {
//                        LazyVStack(alignment: .leading, spacing: 0) {
//                            itemList(items: section.items)
//                        }
//                    }
                }
                .navigationTitle(NoticeToMariners.fullDataSourceName)
                .navigationBarTitleDisplayMode(.inline)
            } label: {
                HStack {
                    Text("View All Notice to Mariners")
                    Spacer()
                }
            }
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            NavigationLink {
                ChartCorrectionQuery()
            } label: {
                HStack {
                    Text("Chart Corrections")
                    Spacer()
                }
            }
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .navigationTitle(NoticeToMariners.fullDataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.grouped)
        .listRowBackground(Color.surfaceColor)
        .background(Color.backgroundColor)
        .foregroundColor(Color.onSurfaceColor)
        .onAppear {
            Metrics.shared.noticeToMarinersView()
        }
    }
}

struct NoticeToMarinersView_Previews: PreviewProvider {
    static var previews: some View {
        NoticeToMarinersView()
    }
}

//
//  NoticeToMarinersView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/11/22.
//

import SwiftUI

struct NoticeToMarinersView: View {
    @Binding var path: NavigationPath
    
    func getFirstDay(WeekNumber weekNumber: Int, CurrentYear currentYear: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dayComponent = DateComponents()
        dayComponent.weekOfYear = weekNumber
        dayComponent.weekday = 7
        dayComponent.yearForWeekOfYear = currentYear
        var date = calendar.date(from: dayComponent)!
        if weekNumber == 1 && calendar.component(.month, from: date) != 1 {
            dayComponent.year = currentYear - 1
            date = calendar.date(from: dayComponent)!
        }
        return date
        
    }

    func dateRange(sectionInt: Int) -> String {
        
        let firstDate = getFirstDay(WeekNumber: sectionInt % 100, CurrentYear: Int(sectionInt / 100)) ?? Date()
        let lastDate = Calendar.current.date(byAdding: .day, value: 6, to: firstDate) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        return "\(dateFormatter.string(from: firstDate)) - \(dateFormatter.string(from: lastDate))"
    }
    
    @ViewBuilder
    func sectionHeader(section: MSISection<NoticeToMariners>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(section.name)
            if let sectionInt = Int(section.name) {
                Text(dateRange(sectionInt: sectionInt))
                    .secondary()
            }
        }
    }

    var body: some View {
        List {
            NavigationLink {
                MSIListView<NoticeToMariners, AnyView, NoticeToMarinersFullNoticeView, EmptyView>(
                    path: $path,
                    watchFocusedItem: false,
                    allowUserSort: false,
                    allowUserFilter: false,
                    sectionHeaderIsSubList: true,
                    sectionGroupNameBuilder: { section in
                    if let sectionInt = Int(section.name) {
                        return "\(Int(sectionInt / 100))"
                    } else {
                        return ""
                    }
                }, sectionViewBuilder: { section in
                    AnyView(sectionHeader(section: section))
                }, content: { section in
                    NoticeToMarinersFullNoticeView(
                        viewModel: NoticeToMarinersFullNoticeViewViewModel(noticeNumber: Int64(section.name)))
                }, emptyView: {
                    EmptyView()
                })
                .navigationTitle(NoticeToMariners.fullDataSourceName)
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    Metrics.shared.appRoute(["ntms", "all"])
                }
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

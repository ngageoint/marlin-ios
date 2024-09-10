//
//  NoticesList.swift
//  Marlin
//
//  Created by Daniel Barela on 2/22/24.
//

import Foundation
import SwiftUI

struct NoticesList: View {
    @StateObject var viewModel: NoticesToMarinersViewModel = NoticesToMarinersViewModel()
    @EnvironmentObject var router: MarlinRouter

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
    func sectionHeader(section: Int) -> some View {

    }
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                VStack(alignment: .center, spacing: 16) {
                    HStack(alignment: .center, spacing: 0) {
                        Spacer()
                        Image("speaker.badge.exclamationmark.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .padding([.trailing, .leading], 24)
                            .foregroundColor(Color.onSurfaceColor)
                        Spacer()
                    }
                    Text("Loading Notices To Mariners")
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.center)
                    ProgressView()
                        .tint(Color.primaryColorVariant)
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.backgroundColor)
                .transition(AnyTransition.opacity)
            case let .loaded(rows: rows):
                ZStack(alignment: .bottomTrailing) {
                    List(rows) { noticeItem in
                        switch noticeItem {
                        case .listItem:
                            EmptyView()
                        case .sectionHeader(let header):
                            Text(header)
                                .onAppear {
                                    if rows.last == noticeItem {
                                        viewModel.loadMore()
                                    }
                                }
                                .sectionHeader()

                        case .week(let noticeNumber):
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(verbatim: "\(noticeNumber)")
                                    Text(dateRange(sectionInt: noticeNumber))
                                        .secondary()
                                }
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                router.path.append(NoticeToMarinersRoute.fullView(noticeNumber: noticeNumber))
                            }
                            .onAppear {
                                if rows.last == noticeItem {
                                    viewModel.loadMore()
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        viewModel.reload()
                    }
                }
                .emptyPlaceholder(rows) {
                    VStack(alignment: .center, spacing: 16) {
                        HStack(alignment: .center, spacing: 0) {
                            Spacer()
                            Image("asam_large")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .padding([.trailing, .leading], 24)
                                .foregroundColor(Color.onSurfaceColor)
                            Spacer()
                        }
                        Text("No Notices match this filter")
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.backgroundColor)
                }
                .transition(AnyTransition.opacity)
            case let .failure(error: error):
                Text(error.localizedDescription)
            }
        }
        .navigationTitle(DataSources.noticeToMariners.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.backgroundColor)
        .foregroundColor(Color.onSurfaceColor)

        .onAppear {
            Metrics.shared.dataSourceList(dataSource: DataSources.noticeToMariners)
        }
    }
}

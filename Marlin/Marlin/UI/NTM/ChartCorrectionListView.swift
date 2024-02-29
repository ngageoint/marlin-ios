//
//  NTMListView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/10/22.
//

import Foundation
import SwiftUI

struct ChartCorrectionList: View {
    
    @ObservedObject var viewModel: ChartCorrectionListViewModel = ChartCorrectionListViewModel()
    
    private let columns = [
        GridItem(.fixed(100)),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    
                    ForEach(Array(viewModel.sortedChartIds), id: \.self) { key in
                        if let group = viewModel.sortedChartCorrections(key: key) {
                            DisclosureGroup {
                                ForEach(group) { ntm in
                                    Divider()
                                    ntmSummary(ntm: ntm)
                                    NTMActionBar(ntm: ntm)
                                }
                                
                            } label: {
                                ntmHeader(ntm: group.first)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.all, 16)
                            .card()
                            .padding(.all, 8)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("\(key)")
                        }
                    }
                    .dataSourceSummaryItem()
                }
            }
            .navigationTitle("Chart Corrections")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.backgroundColor)
            .dataSourceSummaryList()
            .onAppear(perform: viewModel.loadData)
            .tint(Color.primaryColorVariant)
            if viewModel.loading {
                VStack(spacing: 8) {
                    ProgressView()
                        .tint(Color.primaryColorVariant)
                    Text("Loading Chart Corrections...")
                        .primary()
                }
            }
            if let queryError = viewModel.queryError {
                Text("Query Error: \(queryError)")
                    .primary()
                    .padding(.all, 16)
            }
        }
        .onAppear {
            Metrics.shared.appRoute(["ntms", "corrections"])
        }
    }
    
    @ViewBuilder
    func ntmHeader(ntm: ChartCorrection?) -> some View {
        if let ntm = ntm {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let internationalNumber = ntm.intlNumber {
                        Text("Chart No. \(ntm.chartNumber ?? "")")
                            .primary()
                        Text("(INT \(internationalNumber))")
                            .secondary()
                    } else {
                        Text("Chart No. \(ntm.chartNumber ?? "")")
                            .primary()
                    }
                    Spacer()
                    
                    Text("\(ntm.editionNumber ?? "") Ed. \(ntm.editionDate ?? "")")
                        .secondary()
                }
                if let currNoticeNum = ntm.currNoticeNum {
                    HStack {
                        Text("Current Notice: \(currNoticeNum)")
                            .secondary()
                        Spacer()
                        if (ntm.noticeYear >= 99 && ntm.noticeWeek >= 29)
                            || ntm.noticeYear <= Int(Calendar.current.component(.year, from: Date())) % 1000 {
                            NavigationLink(
                                value: NoticeToMarinersRoute.fullView(
                                    getNoticeNumber(noticeNumberString: ntm.currNoticeNum)
                                ),
                                label: {
                                    Text("NTM \(ntm.currNoticeNum ?? "") Details")
                                }
                            )
                            .buttonStyle(MaterialButtonStyle())
                        }
                    }
                }
            }
        }
    }

    func getNoticeNumber(noticeNumberString: String?) -> Int {
        if let noticeNumberString = noticeNumberString {
            let components = noticeNumberString.components(separatedBy: "/")
            if components.count == 2 {
                // notice to mariners that we can obtain only go back to 1999
                if components[1] == "99" {
                    if let noticeNumber =
                        Int("19\(components[1])\(String(format: "%02d", Int(components[0]) ?? 0))") {
                        return noticeNumber
                    }
                } else {
                    if let noticeNumber =
                        Int("20\(components[1])\(String(format: "%02d", Int(components[0]) ?? 0))") {
                        return noticeNumber
                    }
                }
            }
        }
        return -1
    }

    @ViewBuilder
    func ntmSummary(ntm: ChartCorrection) -> some View {
    
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Notice: \(ntm.currNoticeNum ?? "")")
                    .primary()
            }
            if let corrections = ntm.correctionText?.correction {
                LazyVGrid(columns: columns) {
                    ForEach(corrections, id: \.self) { result in
                        HStack(alignment: .top, spacing: 0) {
                            Text(result.action ?? "")
                            Spacer()
                        }
                        HStack(alignment: .center, spacing: 0) {
                            Text(result.text ?? "")
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    .secondary()
                }
            }
            Text("\(ntm.authority ?? "")")
                .secondary()
        }
    }
    
}

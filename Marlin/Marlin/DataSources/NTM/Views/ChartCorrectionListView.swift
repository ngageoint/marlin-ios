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
                LazyVStack(alignment: .leading, spacing: 0) {
                    
                    ForEach(Array(viewModel.sortedChartIds), id: \.self) { key in
                        if let group = viewModel.sortedChartCorrections(key: key) {
                            DisclosureGroup {
                                ForEach(group) { ntm in
                                    Divider()
                                    ntmSummary(ntm: ntm)
                                    NTMActionBar(ntm: ntm)
                                }
                                
                            } label : {
                                ntmHeader(ntm: group.first)
                                
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.all, 16)
                            .card()
                            .padding(.all, 8)
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
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Querying...")
                        .primary()
                }
            }
            if let queryError = viewModel.queryError {
                Text("Query Error: \(queryError)")
                    .primary()
                    .padding(.all, 16)
            }
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
                        if (ntm.noticeYear >= 99 && ntm.noticeWeek >= 29) || ntm.noticeYear <= Int(Calendar.current.component(.year, from: Date()) / 100) % 1000  {
                            NavigationLink {
                                NoticeToMarinersFullNoticeView(viewModel: NoticeToMarinersFullNoticeViewViewModel(noticeNumberString: ntm.currNoticeNum))
                            } label: {
                                Text("NTM \(ntm.currNoticeNum ?? "") Details")
                            }
                            .buttonStyle(MaterialButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func correctionText(ntm: ChartCorrection) -> some View {
        if let corrections = ntm.correctionText?.correction {
            LazyVGrid(columns: columns) {
                ForEach(corrections) { result in
                    HStack(alignment: .top, spacing: 0) {
                        Text(result.action ?? "")
                        Spacer()
                    }
                    HStack(alignment: .center, spacing: 0)  {
                        Text(result.text ?? "")
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
                .secondary()
            }
        }
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
                        HStack(alignment: .center, spacing: 0)  {
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

//
//  NoticeToMarinersView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/11/22.
//

import SwiftUI

struct NoticeToMarinersView: View {
    @EnvironmentObject var noticeToMarinersRepository: NoticeToMarinersRepository
    @StateObject var viewModel: NoticesToMarinersViewModel = NoticesToMarinersViewModel()
    @EnvironmentObject var router: MarlinRouter

    var body: some View {
        List {
            NavigationLink(
                value: NoticeToMarinersRoute.notices,
                label: {
                    HStack {
                        Text("View All Notice to Mariners")
                        Spacer()
                    }
                }
            )
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)

            NavigationLink(
                value: NoticeToMarinersRoute.chartQuery,
                label: {
                    HStack {
                        Text("Chart Corrections")
                        Spacer()
                    }
                }
            )
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .navigationTitle(DataSources.noticeToMariners.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.plain)
        .listRowBackground(Color.surfaceColor)
        .background(Color.backgroundColor)
        .foregroundColor(Color.onSurfaceColor)
        .onAppear {
            Metrics.shared.noticeToMarinersView()
        }
    }
}

//
//  NoticeToMarinersView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/11/22.
//

import SwiftUI

struct NoticeToMarinersView: View {
    @StateObject var viewModel: NoticesToMarinersViewModel = NoticesToMarinersViewModel()
    @EnvironmentObject var router: MarlinRouter

    var body: some View {
        List {
            HStack {
                Text("View All Notice to Mariners")
                Spacer()
                Image(systemName: "chevron.right")
                    .renderingMode(.template)
                    .foregroundColor(Color.onSurfaceColor.opacity(0.36))
            }
            .contentShape(Rectangle())
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .onTapGesture {
                router.path.append(NoticeToMarinersRoute.notices)
            }

            HStack {
                Text("Chart Corrections")
                Spacer()
                Image(systemName: "chevron.right")
                    .renderingMode(.template)
                    .foregroundColor(Color.onSurfaceColor.opacity(0.36))
            }
            .contentShape(Rectangle())
            .padding(.leading, 8)
            .padding(.top, 8)
            .padding(.bottom, 8)
            .onTapGesture {
                router.path.append(NoticeToMarinersRoute.chartQuery)
            }
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

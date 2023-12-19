//
//  NTMActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 11/11/22.
//

import SwiftUI

struct NTMActionBar: View {
        
    var ntm: ChartCorrection

    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            if (ntm.noticeYear >= 99 && ntm.noticeWeek >= 29) || ntm.noticeYear <= Int(Calendar.current.component(.year, from: Date())) % 1000 {
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

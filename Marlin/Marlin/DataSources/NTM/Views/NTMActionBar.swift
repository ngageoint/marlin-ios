//
//  NTMActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 11/11/22.
//

import SwiftUI

struct NTMActionBar: View {
        
    var ntm: ChartCorrection
    
    init(ntm: ChartCorrection) {
        self.ntm = ntm
    }
    
    var body: some View {
        HStack(spacing:8) {
            Spacer()
            if ntm.noticeYear >= 99 || ntm.noticeYear <= Int(Calendar.current.component(.year, from: Date()) / 100) % 1000 {
                NavigationLink {
                    NoticeToMarinersFullNoticeView(noticeNumberString: ntm.currNoticeNum)
                } label: {
                    Text("NTM \(ntm.currNoticeNum ?? "") Details")
                }
                .buttonStyle(MaterialButtonStyle())
            }
        }
    }
}

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
            if (ntm.noticeYear >= 99 && ntm.noticeWeek >= 29) 
                || ntm.noticeYear <= Int(Calendar.current.component(.year, from: Date())) % 1000 {
                NavigationLink(
                    value: NoticeToMarinersRoute.fullView(
                        noticeNumber: getNoticeNumber(noticeNumberString: ntm.currNoticeNum)
                    ),
                    label: {
                        Text("NTM \(ntm.currNoticeNum ?? "") Details")
                    }
                )
                .buttonStyle(MaterialButtonStyle())
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
}

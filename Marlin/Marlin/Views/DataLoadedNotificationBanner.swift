//
//  DataLoadedNotificationBanner.swift
//  Marlin
//
//  Created by Daniel Barela on 2/7/23.
//

import Foundation
import SwiftUI
import Combine

struct DataLoadedNotificationBanner: View {
    @EnvironmentObject var appState: AppState
    
    @State var notificationLineLimit: Int? = 3

    var body: some View {
        Group {
            if let notificationString = appState.consolidatedDataLoadedNotification {
                HStack {
                    Text(notificationString)
                        .font(Font.overline)
                        .foregroundColor(Color.onPrimaryColor)
                        .opacity(0.87)
                        .padding([.top, .bottom], 8)
                        .padding([.leading, .trailing], 16)
                        .multilineTextAlignment(.leading)
                        .lineLimit(notificationLineLimit)
                    Spacer()
                    Button {
                        appState.dataSourceBatchImportNotificationsPending = [:]
                        appState.lastNotificationRequestDate = Date()
                        
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .padding(.trailing, 16)
                    .accessibilityElement()
                    .accessibilityLabel("Clear")
                }
                .accessibilityElement(children: .contain)
                .accessibilityLabel("New Data Loaded\(notificationLineLimit == 3 ? " show more" : "")")
                .background(Color.primaryColor)
                .contentShape(Rectangle())
                .onTapGesture {
                    if notificationLineLimit == 3 {
                        notificationLineLimit = nil
                    } else {
                        notificationLineLimit = 3
                    }
                }
            }
        }
    }
}

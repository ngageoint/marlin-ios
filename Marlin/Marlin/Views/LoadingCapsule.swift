//
//  LoadingCapsule.swift
//  Marlin
//
//  Created by Daniel Barela on 5/23/23.
//

import SwiftUI

struct LoadingCapsule: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            Spacer()
            Capsule()
                .fill(Color.primaryColor)
                .frame(width: 175, height: 25)
                .overlay(
                    HStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.onPrimaryColor))
                            .scaleEffect(0.5, anchor: .center)
                        Text("Loading data")
                            .font(Font.overline)
                            .foregroundColor(Color.onPrimaryColor)
                    }
                )
            Spacer()
        }
        .animation(.default, value: appState.loadingDataSource.values.contains(where: { loading in
            loading
        }))
        .opacity(appState.loadingDataSource.values.contains(where: { loading in
            loading
        }) ? 1.0 : 0.0)
        .padding(.top, 8)
    }
}

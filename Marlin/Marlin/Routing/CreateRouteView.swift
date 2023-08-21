//
//  CreateRouteView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/15/23.
//

import SwiftUI

struct CreateRouteView: View {
    let maxFeatureAreaSize: CGFloat = 300
    @Binding var path: NavigationPath
    
    @State private var contentSize: CGSize = .zero
    @State var waypoints: [String] = []
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack {
                    Text("Choose a Feature")
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 100, height: 100)
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 300, height: 100)
                    Rectangle()
                        .fill(Color.purple)
                        .frame(width: 300, height: 100)
                }
                .overlay(
                    GeometryReader { geo in
                        Color.clear.onAppear {
                            contentSize = CGSize(width: geo.size.width, height: min(geo.size.height, maxFeatureAreaSize))
                        }
                    }
                )
            }
            .scrollDisabled(contentSize.height < maxFeatureAreaSize)
            .background(Color.red)
            .frame(maxWidth: contentSize.width, maxHeight: contentSize.height)
            RouteMapView(path: $path)
                .edgesIgnoringSafeArea([.leading, .trailing])
        }
        .navigationTitle(Route.fullDataSourceName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//
//  EmptyRoutePlaceholder.swift
//  Marlin
//
//  Created by Daniel Barela on 8/15/23.
//

import SwiftUI

struct MultiImageContainerView: View {
    var visibleImage: String
    var maskingImage: String
    
    var body: some View {
        GeometryReader { geo in
            Group {
                ZStack {
                    Image(systemName: visibleImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(0.87)
                        .offset(x: min(geo.size.width, geo.size.height) / 10.0, y: -(min(geo.size.width, geo.size.height) / 15.0))
                        .foregroundColor(Color.onSurfaceColor)
                    Image(systemName: maskingImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.backgroundColor)
                        .tint(Color.backgroundColor)
                        .opacity(1.0)
                    Image(systemName: visibleImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.87)
                }
                .offset(x: -(min(geo.size.width, geo.size.height) / 10.0) / 2.0, y: ((min(geo.size.width, geo.size.height) / 15.0)/2.0))
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
    }
}

struct RouteListEmptyState: View {
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack(alignment: .center, spacing: 0) {
                Spacer()
                MultiImageContainerView(visibleImage: "arrow.triangle.turn.up.right.diamond", maskingImage: "diamond.fill")
                    .frame(maxHeight: .infinity)
                    .padding([.trailing, .leading], 24)
                Spacer()
            }
            Text("No Routes")
                .font(.headline5)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
                .opacity(0.94)
            Text("Create routes between Marlin features for navigation planning.  Routes you create will appear here.")
                .font(.headline6)
                .opacity(0.87)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            CreateRouteButton(showText: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
    }
}

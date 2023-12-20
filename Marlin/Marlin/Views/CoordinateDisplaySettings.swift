//
//  CoordinateDisplaySettings.swift
//  Marlin
//
//  Created by Daniel Barela on 6/30/23.
//

import SwiftUI

struct CoordinateDisplaySettings: View {
    @AppStorage("coordinateDisplay") var coordinateDisplay: CoordinateDisplayType = .latitudeLongitude

    var body: some View {
        Self._printChanges()
        return List {
            HStack(spacing: 4) {
                Text(CoordinateDisplayType.latitudeLongitude.description).font(Font.body1)
                    .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                Spacer()
                Image(
                    systemName: coordinateDisplay == CoordinateDisplayType.latitudeLongitude
                    ? "circle.inset.filled": "circle"
                )
                .foregroundColor(Color.primaryColor)
                .onTapGesture {
                    coordinateDisplay = .latitudeLongitude
                }
                .accessibilityElement()
                .accessibilityLabel(CoordinateDisplayType.latitudeLongitude.description)
            }
            .padding(.top, 4)
            .padding(.bottom, 4)
            HStack(spacing: 4) {
                Text(CoordinateDisplayType.degreesMinutesSeconds.description).font(Font.body1)
                    .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                Spacer()
                Image(
                    systemName: coordinateDisplay == CoordinateDisplayType.degreesMinutesSeconds
                    ? "circle.inset.filled": "circle"
                )
                .foregroundColor(Color.primaryColor)
                .onTapGesture {
                    coordinateDisplay = .degreesMinutesSeconds
                }
                .accessibilityElement()
                .accessibilityLabel(CoordinateDisplayType.degreesMinutesSeconds.description)
            }
            .padding(.top, 4)
            .padding(.bottom, 4)
            HStack(spacing: 4) {
                Text(CoordinateDisplayType.mgrs.description).font(Font.body1)
                    .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                Spacer()
                Image(systemName: coordinateDisplay == CoordinateDisplayType.mgrs ? "circle.inset.filled": "circle")
                    .foregroundColor(Color.primaryColor)
                    .onTapGesture {
                        coordinateDisplay = .mgrs
                    }
                    .accessibilityElement()
                    .accessibilityLabel(CoordinateDisplayType.mgrs.description)
            }
            .padding(.top, 4)
            .padding(.bottom, 4)
            HStack(spacing: 4) {
                Text(CoordinateDisplayType.gars.description).font(Font.body1)
                    .foregroundColor(Color.onSurfaceColor.opacity(0.87))
                Spacer()
                Image(systemName: coordinateDisplay == CoordinateDisplayType.gars ? "circle.inset.filled": "circle")
                    .foregroundColor(Color.primaryColor)
                    .onTapGesture {
                        coordinateDisplay = .gars
                    }
                    .accessibilityElement()
                    .accessibilityLabel(CoordinateDisplayType.gars.description)
            }
            .padding(.top, 4)
            .padding(.bottom, 4)
        }
        .navigationTitle("Coordinate Display Settings")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.grouped)
    }
}

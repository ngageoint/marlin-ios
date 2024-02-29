//
//  NavigationalWarningAreasView.swift
//  Marlin
//
//  Created by Daniel Barela on 5/24/23.
//

import SwiftUI

struct CurrentNavigationalWarningSection: View {
    var navAreaInformation: NavigationalAreaInformation
    var mapName: String?
    var body: some View {
        NavigationalWarningSectionRow(navAreaInformation: navAreaInformation, mapName: mapName)
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(navAreaInformation.navArea.display) (Current)")
            .listRowBackground(Color.surfaceColor)
            .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
    }
}

struct NavigationalWarningAreasView: View {
    @EnvironmentObject var repository: NavigationalWarningRepository
    @ObservedObject var generalLocation = GeneralLocation.shared
    @State var navArea: String?
    var mapName: String?

    @StateObject var viewModel: NavigationalWarningAreasViewModel = NavigationalWarningAreasViewModel()

    @AppStorage("showUnparsedNavigationalWarnings") var showUnparsedNavigationalWarnings = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                if let navArea = viewModel.currentArea {
                    CurrentNavigationalWarningSection(navAreaInformation: navArea, mapName: mapName)
                        .accessibilityLabel("\(navArea.navArea.display) (Current)")
                        .accessibilityElement(children: .contain)
                }
                ForEach(viewModel.warningAreas) { area in

                    NavigationalWarningSectionRow(navAreaInformation: area, mapName: mapName)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("\(area.navArea.display)")
                }
                .listRowBackground(Color.surfaceColor)
                .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
                .accessibilityElement(children: .contain)

                if showUnparsedNavigationalWarnings {
                    NavigationLink(
                        value: NavigationalWarningRoute.areaList(navArea: NavigationalWarningNavArea.UNKNOWN.name)) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Unparsed Locations")
                                    .font(Font.body1)
                                    .foregroundColor(Color.onSurfaceColor)
                                    .opacity(0.87)
                            }
                            Spacer()
                        }
                    }
                    .isDetailLink(false)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Unparsed Locations Navigation Area")
                    .padding(.leading, 8)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    .listRowBackground(Color.surfaceColor)
                    .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
                }
            }
            .listStyle(.plain)
            .listRowBackground(Color.surfaceColor)
            .listRowInsets(EdgeInsets(top: 10, leading: 8, bottom: 8, trailing: 8))
            .onChange(of: generalLocation.currentNavAreaName, perform: { newValue in
                viewModel.currentNavAreaName = newValue
            })
            .onAppear {
                viewModel.currentNavAreaName = generalLocation.currentNavAreaName
                viewModel.repository = repository
            }
            .accessibilityElement(children: .contain)
            NavigationLink(value: MarlinRoute.exportGeoPackageDataSource( dataSource: .navWarning)) {
                Label(
                    title: {},
                    icon: { Image(systemName: "square.and.arrow.down")
                            .renderingMode(.template)
                    }
                )
            }
            .isDetailLink(false)
            .fixedSize()
            .buttonStyle(
                MaterialFloatingButtonStyle(
                    type: .secondary,
                    size: .mini,
                    foregroundColor: Color.onPrimaryColor,
                    backgroundColor: Color.primaryColor))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("Export Button")
            .padding(16)
        }
    }
}

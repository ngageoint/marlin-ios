//
//  PublicationsList.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import SwiftUI

struct PublicationsSectionList: View {
    @EnvironmentObject var router: MarlinRouter
    
    @StateObject var viewModel: PublicationsSectionListViewModel =
    PublicationsSectionListViewModel()

    func publicationTypeRoute(type: PublicationTypeEnum) -> PublicationRoute {
        switch type {
        case .americanPracticalNavigator:
                .completeVolumes(typeId: type.rawValue)
        case .atlasOfPilotCharts,
                .listOfLights,
                .sightReductionTablesForMarineNavigation:
                .nestedFolder(typeId: type.rawValue)
        case .sailingDirectionsPlanningGuides,
                .chartNo1,
                .sailingDirectionsEnroute,
                .sightReductionTablesForAirNavigation,
                .uscgLightList:
                .completeAndChapters(
                    typeId: type.rawValue,
                    title: "Complete Volume(s)",
                    chapterTitle: "Single Chapters"
                )
        case .distanceBetweenPorts,
                .internationalCodeOfSignals,
                .radarNavigationAndManeuveringBoardManual,
                .radioNavigationAids:
                .completeAndChapters(
                    typeId: type.rawValue,
                title: "Complete Volume",
                    chapterTitle: "Single Chapters")
        case .worldPortIndex:
                .completeAndChapters(
                    typeId: type.rawValue,
                title: "Complete Volume",
                chapterTitle: "Additional Formats")
        default:
                .publications(typeId: type.rawValue)
        }
    }
    var body: some View {
        List(viewModel.sections) { section in
            switch section {
            case .pubType(let type, let count):
                folderLabel(
                    name: type.description,
                    count: count
                )
                .accessibilityElement()
                .accessibilityLabel(type.description)
                .contentShape(Rectangle())
                .onTapGesture {
                    router.path.append(publicationTypeRoute(type: type))
                }
            default:
                EmptyView()
            }
        }

        .listStyle(.plain)
        .navigationTitle(DataSources.epub.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Metrics.shared.appRoute(["epubs"])
        }
    }
    
    @ViewBuilder
    func folderLabel(name: String?, count: Int) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "folder.fill")
                .renderingMode(.template)
                .foregroundColor(Color.onSurfaceColor.opacity(0.87))
            VStack(alignment: .leading) {
                Text("\(name ?? "")")
                    .primary()
                Text("\(count) files")
                    .secondary()
            }
            Spacer()
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

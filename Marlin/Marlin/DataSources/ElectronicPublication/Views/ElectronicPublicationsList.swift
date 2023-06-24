//
//  ElectronicPublicationsList.swift
//  Marlin
//
//  Created by Daniel Barela on 10/25/22.
//

import SwiftUI

struct ElectronicPublicationsList: View {    
    @SectionedFetchRequest<Int64, ElectronicPublication>
    var electronicPublicationSections: SectionedFetchResults<Int64, ElectronicPublication>
    
    init() {
        self._electronicPublicationSections = SectionedFetchRequest<Int64, ElectronicPublication>(entity: ElectronicPublication.entity(), sectionIdentifier: \ElectronicPublication.pubTypeId, sortDescriptors: [NSSortDescriptor(keyPath: \ElectronicPublication.pubTypeId, ascending: true)])
    }
    
    var body: some View {
        List {
            ForEach(electronicPublicationSections.sorted(by: { section1, section2 in
                PublicationTypeEnum(rawValue: Int(section1.id))?.description ?? "" < PublicationTypeEnum(rawValue: Int(section2.id))?.description ?? ""
            })) { section in
                NavigationLink {
                    Group {
                        switch(PublicationTypeEnum(rawValue: Int(section.id))) {
                        case .americanPracticalNavigator:
                            completeVolumes(section: section)
                        case .atlasOfPilotCharts, .listOfLights, .sightReductionTablesForMarineNavigation:
                            nestedFolder(section: section)
                        case .sailingDirectionsPlanningGuides, .chartNo1, .sailingDirectionsEnroute, .sightReductionTablesForAirNavigation, .uscgLightList:
                            completeAndChapters(section: section)
                        case .distanceBetweenPorts, .internationalCodeOfSignals, .radarNavigationAndManeuveringBoardManual, .radioNavigationAids:
                            completeAndChapters(section: section, completeTitle: "Complete Volume")
                        case .worldPortIndex:
                            completeAndChapters(section: section, completeTitle: "Complete Volume", chapterTitle: "Additional Formats")
                        default:
                            defaultPublications(section: section)
                        }
                    }
                    .onAppear {
                        Metrics.shared.appRoute(["epubs", PublicationTypeEnum(rawValue: Int(section.id))?.description ?? "pubType"])
                    }
                } label: {
                    folderLabel(name: "\(PublicationTypeEnum(rawValue: Int(section.id))?.description ?? "")", count: section.count)
                        .accessibilityElement()
                        .accessibilityLabel("\(PublicationTypeEnum(rawValue: Int(section.id))?.description ?? "")")
                }
            }
        }
        
        .listStyle(.plain)
        .navigationTitle(ElectronicPublication.fullDataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Metrics.shared.appRoute(["epubs"])
        }
    }
    
    @ViewBuilder
    func defaultPublications(section: SectionedFetchResults<Int64, ElectronicPublication>.Element) -> some View {
        List {
            ForEach(section) { epub in
                epub.summaryView()
                    .padding([.top, .bottom], 16)
            }
        }
        .background(Color.backgroundColor)
        .navigationTitle((PublicationTypeEnum(rawValue: Int(section.id)) ?? .unknown).description)
        .navigationBarTitleDisplayMode(.inline)
        .listRowBackground(Color.surfaceColor)
        .listStyle(.grouped)
    }
    
    @ViewBuilder
    func completeVolumes(section: SectionedFetchResults<Int64, ElectronicPublication>.Element, completeTitle: String = "Complete Volume(s)") -> some View {
        List {
            let completeVolumes = section.filter({ epub in
                epub.fullPubFlag
            }).sorted {
                $0.pubDownloadOrder < $1.pubDownloadOrder
            }
            if !completeVolumes.isEmpty {
                Section(completeTitle) {
                    ForEach(completeVolumes) { epub in
                        epub.summaryView()
                            .padding([.top, .bottom], 16)
                    }
                }
            }
        }
        .background(Color.backgroundColor)
        .navigationTitle((PublicationTypeEnum(rawValue: Int(section.id)) ?? .unknown).description)
        .navigationBarTitleDisplayMode(.inline)
        .listRowBackground(Color.surfaceColor)
        .listStyle(.grouped)
    }
    
    @ViewBuilder
    func completeAndChapters(section: SectionedFetchResults<Int64, ElectronicPublication>.Element, completeTitle: String  = "Complete Volume(s)", chapterTitle: String = "Single Chapters") -> some View {
        List {
            let completeVolumes = section.filter({ epub in
                epub.fullPubFlag
            }).sorted {
                $0.pubDownloadOrder < $1.pubDownloadOrder
            }
            if !completeVolumes.isEmpty {
                Section(completeTitle) {
                    ForEach(completeVolumes) { epub in
                        epub.summaryView()
                            .padding([.top, .bottom], 16)
                    }
                }
            }
            let chapters = section.filter({ epub in
                !epub.fullPubFlag
            }).sorted {
                $0.sectionOrder < $1.sectionOrder
            }
            if !chapters.isEmpty {
                Section(chapterTitle) {
                    ForEach(section.filter({ epub in
                        !epub.fullPubFlag
                    }).sorted {
                        if $0.sectionOrder == $1.sectionOrder {
                            return $0.pubDownloadOrder < $1.pubDownloadOrder
                        }
                        return $0.sectionOrder < $1.sectionOrder
                    }) { epub in
                        epub.summaryView()
                            .padding([.top, .bottom], 16)
                    }
                }
            }
        }
        .background(Color.backgroundColor)
        .navigationTitle((PublicationTypeEnum(rawValue: Int(section.id)) ?? .unknown).description)
        .navigationBarTitleDisplayMode(.inline)
        .listRowBackground(Color.surfaceColor)
        .listStyle(.grouped)
    }
    
    @ViewBuilder
    func nestedFolder(section: SectionedFetchResults<Int64, ElectronicPublication>.Element) -> some View {
        let dictionary: [String? : [SectionedFetchResults<Int64, ElectronicPublication>.Section.Element]] = Dictionary(grouping: section, by: { $0.pubDownloadDisplayName })
        let sortedKeys: [Dictionary<String?, [SectionedFetchResults<Int64, ElectronicPublication>.Section.Element]>.Keys.Element] = dictionary.keys.sorted {
            return dictionary[$0]?[0].pubDownloadOrder ?? -1 < dictionary[$1]?[0].pubDownloadOrder ?? -1
        }
        List {
            ForEach(Array(sortedKeys), id: \.self) { key in
                if let group = dictionary[key], !group.isEmpty {
                    NavigationLink {
                        List {
                            ForEach(group.sorted {
                                return $0.sectionOrder < $1.sectionOrder
                            }, id: \.self) { epub in
                                epub.summaryView()
                                    .padding([.top, .bottom], 16)
                            }
                        }
                        .background(Color.backgroundColor)
                        .listRowBackground(Color.surfaceColor)
                        .listStyle(.plain)
                        .navigationTitle(key ?? "")
                        .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        folderLabel(name: key, count: group.count)
                            .accessibilityElement()
                            .accessibilityLabel(key ?? "")
                    }
                }
            }
        }
        .background(Color.backgroundColor)
        .listRowBackground(Color.surfaceColor)
        .listStyle(.plain)
        .navigationTitle((PublicationTypeEnum(rawValue: Int(section.id)) ?? .unknown).description)
        .navigationBarTitleDisplayMode(.inline)
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
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
    }
}

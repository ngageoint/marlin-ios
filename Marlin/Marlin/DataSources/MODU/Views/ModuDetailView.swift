//
//  ModuDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import SwiftUI
import MapKit
import CoreData

struct ModuDetailView: View {
    @EnvironmentObject var moduRepository: ModuRepositoryManager
    @StateObject var viewModel: ModuViewModel = ModuViewModel()
    @State var name: String
    @State var waypointURI: URL?

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.modu?.itemTitle ?? "")
                        .padding(.all, 8)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .itemTitle()
                        .foregroundColor(Color.white)
                        .background(Color(uiColor: Modu.color))
                        .padding(.bottom, -8)
                    if let modu = viewModel.modu {
                        DataSourceLocationMapView(dataSourceLocation: modu, mapName: "Modu Detail Map", mixins: [ModuMap<ModuModel>(objects: [modu])])
                            .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 300)
                    }
                    Group {
                        Text("\(viewModel.modu?.dateString ?? "")")
                            .overline()
                        Text("\(viewModel.modu?.rigStatus ?? "")")
                            .lineLimit(1)
                            .secondary()
                        Text("\(viewModel.modu?.specialStatus ?? "")")
                            .lineLimit(1)
                            .secondary()
                        BookmarkNotes(notes: viewModel.modu?.bookmark?.notes)
                        if let modu = viewModel.modu {
                            DataSourceActionBar(data: modu)
                                .padding(.bottom, 16)
                        }
                    }.padding([.leading, .trailing], 16)
                }
                .card()
            } header: {
                EmptyView().frame(width: 0, height: 0, alignment: .leading)
            }
            .dataSourceSection()
            
            Section("Additional Information") {
                VStack(alignment: .leading, spacing: 8) {
                    if let distance = viewModel.modu?.distance {
                        Property(property: "Distance", value: distance.zeroIsEmptyString)
                    }
                    Property(property: "Navigational Area", value: viewModel.modu?.navArea)
                    if let subregion = viewModel.modu?.subregion {
                        Property(property: "Charting Subregion", value:subregion.zeroIsEmptyString)
                    }
                }
                .padding(.all, 16)
                .card()
            }
            .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle(viewModel.modu?.name ?? Modu.dataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: name) { newValue in
            viewModel.getModu(name: name, waypointURI: waypointURI)
        }
        .onAppear {
            viewModel.repository = moduRepository
            viewModel.getModu(name: name, waypointURI: waypointURI)
            Metrics.shared.dataSourceDetail(dataSource: Modu.self)
        }
    }
}

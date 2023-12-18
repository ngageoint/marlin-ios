//
//  GeoPackageExportView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/21/23.
//

import SwiftUI

struct GeoPackageExportView: View {
    @EnvironmentObject var dataSourceList: DataSourceList

    @EnvironmentObject var asamRepository: AsamRepository
    @EnvironmentObject var moduRepository: ModuRepositoryManager
    @EnvironmentObject var lightRepository: LightRepositoryManager
    @EnvironmentObject var portRepository: PortRepositoryManager
    @EnvironmentObject var dgpsRepository: DifferentialGPSStationRepositoryManager
    @EnvironmentObject var radioBeaconRepository: RadioBeaconRepositoryManager
    @EnvironmentObject var routeRepository: RouteRepositoryManager
    @EnvironmentObject var navigationalWarningRepository: NavigationalWarningRepositoryManager

    @StateObject var viewModel: GeoPackageExportViewModel = GeoPackageExportViewModel()
    
    @State var exportRequest: [DataSourceExportRequest] = []
    
    @State var dataSources: [DataSourceDefinitions]
    @State var filters: [DataSourceFilterParameter]?
    @State var useMapRegion: Bool
    
    var body: some View {
        VStack {
            ScrollView {
                HStack {
                    Text("Included Data Sources".uppercased())
                        .overline()
                        .padding(.top, 8)
                        .padding(.all, 8)
                    Spacer()
                }
                HStack {
                    ForEach(dataSourceList.mappableDataSources, id: \.self) { dataSourceItem in
                        let included = viewModel.dataSources.contains { definition in
                            definition.key == dataSourceItem.key
                        }
                        dataSourceButton(definition: dataSourceItem.dataSource.definition, enabled: included)
                    }
                }
                if !viewModel.exporting && !viewModel.complete {
                    commonFilters(viewModel: viewModel.commonViewModel)
                }
                dataSourceFilters(
                    dataSources: viewModel.dataSourceDefinitions,
                    exportProgresses: viewModel.exportProgresses,
                    filterViewModels: viewModel.filterViewModels,
                    counts: viewModel.counts,
                    exporting: viewModel.exporting)
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            HStack {
                Spacer()
                if viewModel.complete {
                    if let path = viewModel.geoPackage?.path {
                        ShareLink(
                            item: URL(fileURLWithPath: path)
                        ) {
                            Label(
                                title: {
                                    Text("Share Export")
                                },
                                icon: { Image(systemName: "square.and.arrow.up")
                                        .renderingMode(.template)
                                })
                        }
                        .accessibilityElement()
                        .accessibilityLabel("share")
                        .buttonStyle(MaterialButtonStyle(type: .contained))
                        .padding(.all, 16)
                    }
                } else if !viewModel.exporting {
                    Button {
                        viewModel.export()
                    } label: {
                        Label(
                            title: {
                                Text("Export")
                            },
                            icon: { Image(systemName: "square.and.arrow.down")
                                    .renderingMode(.template)
                            }
                        )
                    }
                    .buttonStyle(MaterialButtonStyle(type: .contained))
                    .padding(.all, 16)
                }
            }
        })
        .navigationTitle("GeoPackage Export")
        .background(Color.backgroundColor)
        .onAppear {
            viewModel.asamRepository = asamRepository
            viewModel.moduRepository = moduRepository
            viewModel.lightRepository = lightRepository
            viewModel.portRepository = portRepository
            viewModel.dgpsRepository = dgpsRepository
            viewModel.radioBeaconRepository = radioBeaconRepository
            viewModel.routeRepository = routeRepository
            viewModel.navigationalWarningRepository = navigationalWarningRepository
            viewModel.setExportParameters(dataSources: dataSources, filters: filters, useMapRegion: useMapRegion)
            Metrics.shared.geoPackageExportView()
        }
        .onChange(of: viewModel.complete) { _ in
            guard let path = viewModel.geoPackage?.path else { return }
            let activityVC = UIActivityViewController(activityItems: [URL(fileURLWithPath: path)], applicationActivities: nil)
            UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
        }
        .alert("Export Error", isPresented: $viewModel.error) {
            Button("OK") { }
        } message: {
            Text("""
                We apologize, it looks like we were unable to export Marlin data for the selected data \
                sources.  Please try again later or reach out if this issue persists.
            """)
        }
    }
    
    @ViewBuilder
    func dataSourceButton(
        definition: any DataSourceDefinition,
        enabled: Bool
    ) -> some View {
        Button(action: {
            viewModel.toggleDataSource(definition: definition)
        }) {
            Label(title: {}) {
                if let image = definition.image {
                    Image(uiImage: image)
                        .renderingMode(.template)
                        .tint(Color.white)
                }
            }
        }
        .buttonStyle(
            MaterialFloatingButtonStyle(
                type: .custom,
                size: .mini,
                foregroundColor: enabled ? Color.white : Color.disabledColor,
                backgroundColor: enabled ? Color(uiColor: definition.color) : Color.disabledBackground))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(definition.key) Export Toggle")
    }
    
    @ViewBuilder
    func commonFilters(
        viewModel: FilterViewModel
    ) -> some View {
        HStack {
            Text("Common Filters".uppercased())
                .overline()
                .padding(.top, 8)
                .padding(.all, 8)
            Spacer()
        }
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                DisclosureGroup {
                    FilterView(viewModel: viewModel)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("\(viewModel.dataSource?.definition.fullName ?? "") filters")
                } label: {
                    ExportFilterLabel(viewModel: viewModel, count: 0)
                        .contentShape(Rectangle())
                        .padding([.leading, .top, .bottom, .trailing], 16)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("\(viewModel.dataSource?.definition.fullName ?? "") filters")
                }
                .disabled(true)
                .padding(.trailing, 16)
                .contentShape(Rectangle())
                .accessibilityElement(children: .contain)
                .accessibilityLabel("expand \(viewModel.dataSource?.definition.fullName ?? "") filters")
                .background(
                    HStack {
                        Rectangle()
                            .fill(Color(viewModel.dataSource?.definition.color ?? .clear))
                            .frame(maxWidth: 8, maxHeight: .infinity)
                        Spacer()
                    }
                        .background(Color.surfaceColor)
                )
                .tint(Color.primaryColorVariant)
            }
            Divider()
        }
    }
    
    @ViewBuilder
    func dataSourceFilters(
        dataSources: [DataSourceDefinitions],
        exportProgresses: [DataSourceDefinitions: DataSourceExportProgress],
        filterViewModels: [DataSourceDefinitions: FilterViewModel],
        counts: [DataSourceDefinitions: Int],
        exporting: Bool
    ) -> some View {
        HStack {
            Text("Data Source Filters".uppercased())
                .overline()
                .padding(.top, 8)
                .padding(.all, 8)
            Spacer()
        }
        VStack(spacing: 0) {
            ForEach(dataSources.sorted(by: { d1, d2 in
                d1.definition.order < d2.definition.order
            })) { dataSourceDefinition in
                if let progress = exportProgresses[dataSourceDefinition], 
                    let viewModel = filterViewModels[dataSourceDefinition] {
                    ExportFilterRow(
                        exporting: exporting,
                        progress: progress,
                        viewModel: viewModel,
                        count: counts[dataSourceDefinition] ?? 0)
                    Divider()
                }
            }
            .background(Color.surfaceColor)
        }
    }
}

struct ExportFilterLabel: View {
    @ObservedObject var viewModel: FilterViewModel
    var count: Int
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let systemImageName = viewModel.dataSource?.definition.systemImageName {
                Image(systemName: systemImageName)
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
            } else if let imageName = viewModel.dataSource?.definition.imageName {
                Image(imageName)
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
            }
            
            Text(viewModel.dataSource?.definition.fullName ?? "")
                .primary()
                .multilineTextAlignment(.leading)
            Spacer()
            if viewModel.dataSource?.definition.key == CommonDataSource.key {
                Text("\(viewModel.filters.count) common filter\(viewModel.filters.count == 1 ? "" : "s") set")
                    .overline()
            } else {
                Text("\(count)")
                    .overline()
            }
        }
    }
}

struct ExportFilterRow: View {
    @State var filterCount: Int = 0
    var exporting: Bool
    @ObservedObject var progress: DataSourceExportProgress
    @ObservedObject var viewModel: FilterViewModel
    var count: Int

    var body: some View {
        Self._printChanges()
        return Group {
                if exporting {
                    VStack(alignment: .leading) {
                        ExportFilterLabel(viewModel: viewModel, count: count)
                            .contentShape(Rectangle())
                            .padding([.leading, .top, .bottom, .trailing], 16)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel(
                                "\(filterCount) \(viewModel.dataSource?.definition.fullName ?? "") filters")

                        ProgressView(value: progress.exportCount, total: progress.totalCount)
                            .progressViewStyle(.linear)
                            .tint(Color.primaryColorVariant)
                    }
                } else {
                    DisclosureGroup {
                        FilterView(viewModel: viewModel)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("\(viewModel.dataSource?.definition.fullName ?? "") filters")
                    } label: {
                        ExportFilterLabel(viewModel: viewModel, count: count)
                            .contentShape(Rectangle())
                            .padding([.leading, .top, .bottom, .trailing], 16)
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel(
                                "\(filterCount) \(viewModel.dataSource?.definition.fullName ?? "") filters")
                    }
                    .padding(.trailing, 16)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("expand \(viewModel.dataSource?.definition.fullName ?? "") filters")
                }
            }
            .contentShape(Rectangle())
            .background(
                HStack {
                    Rectangle()
                        .fill(Color(viewModel.dataSource?.definition.color ?? .clear))
                        .frame(maxWidth: 8, maxHeight: .infinity)
                    Spacer()
                }
                .background(Color.surfaceColor)
            )
            .tint(Color.primaryColorVariant)
        }
}

struct ExportProgressRow: View {
    @State var filterCount: Int = 0
    
    @ObservedObject var progress: DataSourceExportProgress
    @ObservedObject var viewModel: FilterViewModel
    var count: Int
    
    var body: some View {
        Self._printChanges()
        return VStack(alignment: .leading) {
            VStack {
                ExportFilterLabel(viewModel: viewModel, count: count)
                    .contentShape(Rectangle())
                    .padding([.leading, .top, .bottom, .trailing], 16)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("\(filterCount) \(viewModel.dataSource?.definition.fullName ?? "") filters")
                
                ProgressView(value: progress.exportCount, total: progress.totalCount)
                    .progressViewStyle(.linear)
                    .tint(Color.primaryColorVariant)
            }
            .contentShape(Rectangle())
            .accessibilityElement(children: .contain)
            .accessibilityLabel("export \(progress.filterable.definition.fullName) progress")
            .background(
                HStack {
                    Rectangle()
                        .fill(Color(progress.filterable.definition.color))
                        .frame(maxWidth: 8, maxHeight: .infinity)
                    Spacer()
                }
                    .background(Color.surfaceColor)
            )
            .tint(Color.primaryColorVariant)
        }
    }
}


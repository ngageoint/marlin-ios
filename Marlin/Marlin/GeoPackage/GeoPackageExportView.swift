//
//  GeoPackageExportView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/21/23.
//

import SwiftUI

struct GeoPackageExportView: View {
    @EnvironmentObject var dataSourceList: DataSourceList

    @StateObject var exporter: GeoPackageExporter = GeoPackageExporter()
    
    @State var exportRequest: [DataSourceExportRequest]
    
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
                        let included = exporter.filterViewModels.contains { viewModel in
                            viewModel.dataSource.key == dataSourceItem.key
                        }
                        
                        Button(action: {
                            if exporter.exporting {
                                return
                            }
                            if included {
                                exporter.removeExportDataSource(dataSourceItem: dataSourceItem)
                            } else {
                                exporter.addExportDataSource(dataSourceItem: dataSourceItem)
                            }
                        }) {
                            Label(title: {}) {
                                if let image = dataSourceItem.dataSource.image {
                                    Image(uiImage: image)
                                        .renderingMode(.template)
                                        .tint(Color.white)
                                }
                            }
                        }
                        .buttonStyle(MaterialFloatingButtonStyle(type: .custom, size: .mini, foregroundColor: included ? Color.white : Color.disabledColor, backgroundColor: included ? Color(uiColor: dataSourceItem.dataSource.color) : Color.disabledBackground))
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("\(dataSourceItem.dataSource.key) Export Toggle")
                    }
                }
                if !exporter.exporting && !exporter.complete {
                    HStack {
                        Text("Common Filters".uppercased())
                            .overline()
                            .padding(.top, 8)
                            .padding(.all, 8)
                        Spacer()
                    }
                    VStack(spacing: 0) {
                        ExportFilterRow(viewModel: exporter.commonViewModel)
                        Divider()
                    }
                    
                    HStack {
                        Text("Data Source Filters".uppercased())
                            .overline()
                            .padding(.top, 8)
                            .padding(.all, 8)
                        Spacer()
                    }
                    VStack(spacing: 0) {
                        ForEach(exporter.filterViewModels) { viewModel in
                            ExportFilterRow(viewModel: viewModel)
                            Divider()
                        }
                        .background(Color.surfaceColor)
                    }
                } else {
                    HStack {
                        Text("Export Status".uppercased())
                            .overline()
                            .padding(.top, 8)
                            .padding(.all, 8)
                        Spacer()
                    }
                    VStack(spacing: 0) {
                        ForEach(exporter.exportProgresses) { progress in
                            if progress.totalCount != 0.0 {
                                ExportProgressRow(progress: progress)
                                Divider()
                            }
                        }
                        .background(Color.surfaceColor)
                    }
                }
            }
            if let creationError = exporter.creationError {
                Text("Error \(creationError)")
            }
        }
        .safeAreaInset(edge: .bottom, content: {
            HStack {
                Spacer()
                if exporter.complete {
                    if let path = exporter.geoPackage?.path {
                        ShareLink(
                            item: URL(fileURLWithPath: path)
                        ) {
                            Label(
                                title: {
                                    Text("Download Created GeoPackage")
                                },
                                icon: { Image(systemName: "square.and.arrow.up")
                                        .renderingMode(.template)
                                })
                        }
                        .accessibilityElement()
                        .accessibilityLabel("share")
                        .buttonStyle(MaterialButtonStyle(type:.contained))
                        .padding(.all, 16)
                    }
                } else if !exporter.exporting {
                    Button {
                        exporter.export()
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
                    .buttonStyle(MaterialButtonStyle(type:.contained))
                    .padding(.all, 16)
                }
            }
        })
        .navigationTitle("GeoPackage Export")
        .background(Color.backgroundColor)
        .onAppear {
            exporter.setExportRequests(exportRequests: exportRequest)
        }
    }
}

struct ExportProgressRow: View {
    @State var filterCount: Int = 0
    
    @ObservedObject var progress: DataSourceExportProgress
    
    var body: some View {
        Self._printChanges()
        return VStack(alignment: .leading) {
            VStack {
                HStack(alignment: .center, spacing: 8) {
                    if let systemImageName = progress.dataSource.systemImageName {
                        Image(systemName: systemImageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    } else if let imageName = progress.dataSource.imageName {
                        Image(imageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    }
                    
                    Text(progress.dataSource.fullDataSourceName)
                        .primary()
                        .multilineTextAlignment(.leading)
                    Spacer()
                    Text("\(Int(progress.totalCount))")
                        .overline()
                }
                .contentShape(Rectangle())
                .padding([.leading, .top, .bottom, .trailing], 16)
                
                ProgressView(value: progress.exportCount, total: progress.totalCount)
                    .progressViewStyle(.linear)
                    .tint(Color.primaryColorVariant)
            }
            .contentShape(Rectangle())
            .accessibilityElement(children: .contain)
            .accessibilityLabel("export \(progress.dataSource.fullDataSourceName) progress")
            .background(
                HStack {
                    Rectangle()
                        .fill(Color(progress.dataSource.color))
                        .frame(maxWidth: 8, maxHeight: .infinity)
                    Spacer()
                }
                    .background(Color.surfaceColor)
            )
            .tint(Color.primaryColorVariant)
        }
    }
}

struct ExportFilterLabel: View {
    @ObservedObject var viewModel: TemporaryFilterViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if let systemImageName = viewModel.dataSource.systemImageName {
                Image(systemName: systemImageName)
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
            } else if let imageName = viewModel.dataSource.imageName {
                Image(imageName)
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
            }
            
            Text(viewModel.dataSource.fullDataSourceName)
                .primary()
                .multilineTextAlignment(.leading)
            Spacer()
            if viewModel.dataSource.key == CommonDataSource.key {
                Text("\(viewModel.filters.count) common filter\(viewModel.filters.count == 1 ? "" : "s") set")
                    .overline()
            } else {
                Text("\(viewModel.count)")
                    .overline()
            }
        }
    }
}

struct ExportFilterRow: View {
    @State var filterCount: Int = 0
    @ObservedObject var viewModel: TemporaryFilterViewModel

    var body: some View {
        Self._printChanges()
        return VStack(alignment: .leading) {
            DisclosureGroup {
                FilterView(viewModel: viewModel)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("\(viewModel.dataSource.fullDataSourceName) filters")
            } label: {
                ExportFilterLabel(viewModel: viewModel)
                    .contentShape(Rectangle())
                    .padding([.leading, .top, .bottom, .trailing], 16)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("\(filterCount) \(viewModel.dataSource.fullDataSourceName) filters")
            }
            .padding(.trailing, 16)
            .contentShape(Rectangle())
            .accessibilityElement(children: .contain)
            .accessibilityLabel("expand \(viewModel.dataSource.fullDataSourceName) filters")
            .background(
                HStack {
                    Rectangle()
                        .fill(Color(viewModel.dataSource.color))
                        .frame(maxWidth: 8, maxHeight: .infinity)
                    Spacer()
                }
                .background(Color.surfaceColor)
            )
            .tint(Color.primaryColorVariant)
        }
    }
}

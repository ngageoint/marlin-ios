//
//  FilterBottomSheetRow.swift
//  Marlin
//
//  Created by Daniel Barela on 9/28/22.
//

import SwiftUI

struct FilterBottomSheetRow: View {
    @Binding var dataSourceItem: DataSourceItem
    @State var filterCount: Int = 0
    let dataSourceUpdatedPub = NotificationCenter.default.publisher(for: .DataSourceUpdated)
    
    var body: some View {
        VStack(alignment: .leading) {
            DisclosureGroup {
                let dataSourceType = dataSourceItem.dataSource
                FilterView(viewModel: PersistedFilterViewModel(dataSource: dataSourceType))
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("\(dataSourceItem.dataSource.fullDataSourceName) filters")
            } label : {
                HStack(alignment: .center, spacing: 8) {
                    
                    if let systemImageName = dataSourceItem.dataSource.systemImageName {
                        Image(systemName: systemImageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    } else if let imageName = dataSourceItem.dataSource.imageName {
                        Image(imageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    }
                    
                    Text(dataSourceItem.dataSource.fullDataSourceName)
                        .primary()
                    Spacer()
                    if filterCount != 0 {
                        Image(systemName: "\(filterCount).circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Color.white, Color.secondaryColor)
                    }
                }
                .contentShape(Rectangle())
                .padding([.leading, .top, .bottom, .trailing], 16)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("\(filterCount) \(dataSourceItem.dataSource.fullDataSourceName) filters")
            }
            .padding(.trailing, 16)
            .contentShape(Rectangle())
            .accessibilityElement(children: .contain)
            .accessibilityLabel("expand \(dataSourceItem.dataSource.fullDataSourceName) filters")
            
            .background(
                
                HStack {
                    Rectangle()
                        .fill(Color(dataSourceItem.dataSource.color))
                        .frame(maxWidth: 8, maxHeight: .infinity)
                    Spacer()
                }
                    .background(Color.surfaceColor)
            )
            .tint(Color.primaryColorVariant)
        }
        .onReceive(dataSourceUpdatedPub) { output in
            filterCount = UserDefaults.standard.filter(dataSourceItem.dataSource).count
        }
        .onAppear {
            filterCount = UserDefaults.standard.filter(dataSourceItem.dataSource).count
        }
    }
}

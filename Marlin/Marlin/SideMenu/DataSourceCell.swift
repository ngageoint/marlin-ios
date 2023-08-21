//
//  DataSourceCell.swift
//  Marlin
//
//  Created by Daniel Barela on 7/5/22.
//

import SwiftUI

struct DataSourceCell: View {    
    @ObservedObject var dataSourceItem: DataSourceItem
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                
                Group {
                    if let loading = appState.loadingDataSource[dataSourceItem.key], loading {
                        HStack(alignment: .center) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.primaryColorVariant))
                                .scaleEffect(0.75, anchor: .center)
                                .accessibilityElement()
                                .accessibilityLabel("Loading \(dataSourceItem.dataSource.key)")
                        }
                    } else {
                        if let systemImageName = dataSourceItem.dataSource.systemImageName {
                            Image(systemName: systemImageName)
                                .tint(Color.onSurfaceColor)
                                .opacity(0.60)
                        } else if let imageName = dataSourceItem.dataSource.imageName {
                            Image(imageName)
                                .tint(Color.onSurfaceColor)
                                .opacity(0.60)
                        }
                    }
                }.padding([.leading, .trailing], 8)
                
                Text(dataSourceItem.dataSource.fullDataSourceName)
                    .primary()

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                NotificationCenter.default.post(name: .SwitchTabs, object: dataSourceItem.key)
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(dataSourceItem.key) cell")
            .padding([.leading, .top, .bottom, .trailing], 16)
            Divider()
        }
        .background(
            
            HStack {
                Rectangle()
                    .fill(Color(dataSourceItem.dataSource.color))
                    .frame(maxWidth: 8, maxHeight: .infinity)
                Spacer()
                }
                .background(Color.surfaceColor)
        )

    }
}

//
//  FilterBottomSheetRow.swift
//  Marlin
//
//  Created by Daniel Barela on 9/28/22.
//

import SwiftUI

struct FilterBottomSheetRow: View {
//    @Binding var filterable: Filterable
    // TODO: refactor- is this right
    var filterable: Filterable
    @State var filterCount: Int = 0
    let dataSourceUpdatedPub = NotificationCenter.default.publisher(for: .DataSourceUpdated)
    
    var body: some View {
        VStack(alignment: .leading) {
            DisclosureGroup {
                FilterView(viewModel: PersistedFilterViewModel(dataSource: filterable))
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("\(filterable.definition.fullName) filters")
            } label: {
                HStack(alignment: .center, spacing: 8) {
                    
                    if let systemImageName = filterable.definition.systemImageName {
                        Image(systemName: systemImageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    } else if let imageName = filterable.definition.imageName {
                        Image(imageName)
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                    }
                    
                    Text(filterable.definition.fullName)
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
                .accessibilityLabel("\(filterCount) \(filterable.definition.fullName) filters")
            }
            .padding(.trailing, 16)
            .contentShape(Rectangle())
            .accessibilityElement(children: .contain)
            .accessibilityLabel("expand \(filterable.definition.fullName) filters")
            
            .background(
                
                HStack {
                    Rectangle()
                        .fill(Color(filterable.definition.color))
                        .frame(maxWidth: 8, maxHeight: .infinity)
                    Spacer()
                }
                    .background(Color.surfaceColor)
            )
            .tint(Color.primaryColorVariant)
        }
        .onReceive(dataSourceUpdatedPub) { _ in
            filterCount = UserDefaults.standard.filter(filterable.definition).count
        }
        .onAppear {
            filterCount = UserDefaults.standard.filter(filterable.definition).count
        }
    }
}

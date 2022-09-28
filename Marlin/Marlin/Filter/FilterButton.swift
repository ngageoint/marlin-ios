//
//  FilterButton.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//

import SwiftUI

struct FilterButton: ViewModifier {
    @AppStorage("filterEnabled") var filterEnabled = false

    @Binding var filterOpen: Bool
    @Binding var dataSources: [DataSourceItem]
    @State var filterCount: Int = 0
    @State var filterCounts: [String : Int] = [:]
    let dataSourceUpdatedPub = NotificationCenter.default.publisher(for: .DataSourceUpdated)
    
    init(filterOpen: Binding<Bool>, dataSources: Binding<[DataSourceItem]> = Binding.constant([])) {
        self._filterOpen = filterOpen
        self._dataSources = dataSources
    }
    
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem (placement: .navigationBarTrailing)  {
                if filterEnabled {
                    HStack {
                        Button(action: {
                            filterOpen.toggle()
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .imageScale(.large)
                                .foregroundColor(Color.onPrimaryColor)
                                .overlay(Badge(count: filterCount))
                        }
                        .padding(.all, 10)
                    }
                }
            }
        }
        .onAppear {
            var count = 0
            for dataSource in dataSources {
                count += UserDefaults.standard.filter(dataSource.dataSource.key).count
            }
            filterCount = count
        }
        .onReceive(dataSourceUpdatedPub) { output in
            var count = 0
            for dataSource in dataSources {
                count += UserDefaults.standard.filter(dataSource.dataSource.key).count
            }
            filterCount = count
        }
        .onChange(of: dataSources) { newValue in
            var count = 0
            for dataSource in dataSources {
                count += UserDefaults.standard.filter(dataSource.dataSource.key).count
            }
            filterCount = count
        }
    }
}

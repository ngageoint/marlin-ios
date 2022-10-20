//
//  FilterButton.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//

import SwiftUI

struct FilterButton: ViewModifier {
    @AppStorage("filterEnabled") var filterEnabled = false
    @AppStorage("sortEnabled") var sortEnabled = false

    @Binding var filterOpen: Bool
    @Binding var sortOpen: Bool
    @Binding var dataSources: [DataSourceItem]
    @State var filterCount: Int = 0
    @State var filterCounts: [String : Int] = [:]
    var allowSorting: Bool
    let dataSourceUpdatedPub = NotificationCenter.default.publisher(for: .DataSourceUpdated)
    
    init(filterOpen: Binding<Bool>, sortOpen: Binding<Bool>, dataSources: Binding<[DataSourceItem]> = Binding.constant([])) {
        self._filterOpen = filterOpen
        self._dataSources = dataSources
        self._sortOpen = sortOpen
        allowSorting = true
    }
    
    init(filterOpen: Binding<Bool>, dataSources: Binding<[DataSourceItem]> = Binding.constant([])) {
        self._filterOpen = filterOpen
        self._dataSources = dataSources
        allowSorting = false
        self._sortOpen = Binding.constant(false)
    }
    
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem (placement: .navigationBarTrailing)  {
                
                HStack(spacing: 0) {
                    if sortEnabled && allowSorting {
                        Button(action: {
                            sortOpen.toggle()
                        }) {
                            Image(systemName: "arrow.up.arrow.down")
                                .imageScale(.large)
                                .foregroundColor(Color.onPrimaryColor)
                        }
                        .padding([.top, .bottom], 10)
                        .padding(.trailing, 5)
                    }
                    if filterEnabled {
                        Button(action: {
                            filterOpen.toggle()
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .imageScale(.large)
                                .foregroundColor(Color.onPrimaryColor)
                                .overlay(Badge(count: filterCount))
                        }
                        .padding([.top, .bottom], 10)
                        .padding(.leading, 5)
                    }
                }
                
            }
        }
        .onAppear {
            var count = 0
            for dataSource in dataSources {
                count += UserDefaults.standard.filter(dataSource.dataSource).count
            }
            filterCount = count
        }
        .onReceive(dataSourceUpdatedPub) { output in
            var count = 0
            for dataSource in dataSources {
                count += UserDefaults.standard.filter(dataSource.dataSource).count
            }
            filterCount = count
        }
        .onChange(of: dataSources) { newValue in
            var count = 0
            for dataSource in dataSources {
                count += UserDefaults.standard.filter(dataSource.dataSource).count
            }
            filterCount = count
        }
    }
}

//
//  FilterButton.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//

import SwiftUI

struct FilterButton: ViewModifier {
    @Binding var filterOpen: Bool
    @Binding var sortOpen: Bool
    @Binding var dataSources: [DataSourceItem]
    @State var filterCount: Int = 0
    @State var filterCounts: [String: Int] = [:]
    var allowSorting: Bool
    var allowFiltering: Bool
    let dataSourceUpdatedPub = NotificationCenter.default.publisher(for: .DataSourceUpdated)
    
    init(filterOpen: Binding<Bool>, sortOpen: Binding<Bool>, dataSources: Binding<[DataSourceItem]> = Binding.constant([]), allowSorting: Bool = true, allowFiltering: Bool = true) {
        self._filterOpen = filterOpen
        self._dataSources = dataSources
        self._sortOpen = sortOpen
        self.allowSorting = allowSorting
        self.allowFiltering = allowFiltering
    }
    
    init(filterOpen: Binding<Bool>, dataSources: Binding<[DataSourceItem]> = Binding.constant([]), allowSorting: Bool = false, allowFiltering: Bool = true) {
        self._filterOpen = filterOpen
        self._dataSources = dataSources
        self.allowSorting = allowSorting
        self.allowFiltering = allowFiltering
        self._sortOpen = Binding.constant(false)
    }
    
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                
                HStack(spacing: 0) {
                    if allowSorting {
                        Button(action: {
                            sortOpen.toggle()
                        }) {
                            Image(systemName: "arrow.up.arrow.down")
                                .imageScale(.large)
                                .foregroundColor(Color.onPrimaryColor)
                        }
                        .contentShape(Rectangle())
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Sort")
                    }
                    if allowFiltering {
                        Button(action: {
                            filterOpen.toggle()
                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .imageScale(.large)
                                .foregroundColor(Color.onPrimaryColor)
                                .overlay(Badge(count: filterCount)
                                    .accessibilityElement()
                                    .accessibilityLabel("\(filterCount) filter"))
                        }
                        .contentShape(Rectangle())
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Filter")
                    }
                }
            }
        }
        .onAppear {
            var count = 0
            for dataSource in dataSources {
                count += UserDefaults.standard.filter(dataSource.dataSource.definition).count
            }
            filterCount = count
        }
        .onReceive(dataSourceUpdatedPub) { _ in
            var count = 0
            for dataSource in dataSources {
                count += UserDefaults.standard.filter(dataSource.dataSource.definition).count
            }
            filterCount = count
        }
        .onChange(of: dataSources) { _ in
            var count = 0
            for dataSource in dataSources {
                count += UserDefaults.standard.filter(dataSource.dataSource.definition).count
            }
            filterCount = count
        }
    }
}

//
//  FilterButton.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//
import SwiftUI

struct CombinedSourcesFilterButton: ViewModifier {
    @Binding var filterOpen: Bool
    @Binding var dataSources: [DataSourceItem]
    @State var filterCount: Int = 0
    @State var filterCounts: [String: Int] = [:]
    var allowFiltering: Bool
    let dataSourceUpdatedPub = NotificationCenter.default.publisher(for: .DataSourceUpdated)
    
    init(
        filterOpen: Binding<Bool>,
        dataSources: Binding<[DataSourceItem]> = Binding.constant([]),
        allowFiltering: Bool = true
    ) {
        self._filterOpen = filterOpen
        self._dataSources = dataSources
        self.allowFiltering = allowFiltering
    }
    
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                if allowFiltering {
                    filterButton()
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
        .onReceive(dataSourceUpdatedPub) { _ in
            var count = 0
            for dataSource in dataSources {
                count += UserDefaults.standard.filter(dataSource.dataSource).count
            }
            filterCount = count
        }
        .onChange(of: dataSources) { _ in
            var count = 0
            for dataSource in dataSources {
                count += UserDefaults.standard.filter(dataSource.dataSource).count
            }
            filterCount = count
        }
    }

    @ViewBuilder
    func filterButton() -> some View {
        Button(
            action: {
                filterOpen.toggle()
            },
            label: {
                Image(systemName: "slider.horizontal.3")
                    .imageScale(.large)
                    .foregroundColor(Color.onPrimaryColor)
                    .overlay(Badge(count: filterCount)
                        .accessibilityElement()
                        .accessibilityLabel("\(filterCount) filter"))
            }
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Filter")
    }
}

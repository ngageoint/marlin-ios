//
//  DataSourceFilterAndSort.swift
//  Marlin
//
//  Created by Daniel Barela on 3/6/24.
//

import Foundation
import SwiftUI
struct DataSourceFilterAndSort: ViewModifier {
    @Binding var filterOpen: Bool
    @Binding var sortOpen: Bool
    @State var filterCount: Int = 0
    @State var filterCounts: [String: Int] = [:]
    var allowSorting: Bool
    var allowFiltering: Bool
    @ObservedObject var filterViewModel: FilterViewModel
    let dataSourceUpdatedPub = NotificationCenter.default.publisher(for: .DataSourceUpdated)

    init(
        filterOpen: Binding<Bool>,
        sortOpen: Binding<Bool>,
        filterViewModel: FilterViewModel,
        allowSorting: Bool = true,
        allowFiltering: Bool = true
    ) {
        self._filterOpen = filterOpen
        self._sortOpen = sortOpen
        self.filterViewModel = filterViewModel
        self.allowSorting = allowSorting
        self.allowFiltering = allowFiltering
    }

    init(
        filterOpen: Binding<Bool>,
        filterViewModel: FilterViewModel,
        allowSorting: Bool = false,
        allowFiltering: Bool = true
    ) {
        self._filterOpen = filterOpen
        self.filterViewModel = filterViewModel
        self.allowSorting = allowSorting
        self.allowFiltering = allowFiltering
        self._sortOpen = Binding.constant(false)
    }

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {

                HStack(spacing: 0) {
                    if allowSorting {
                        sortButton()
                    }
                    if allowFiltering {
                        filterButton()
                    }
                }
            }
        }
        .onAppear {
            if let definition = filterViewModel.dataSource?.definition {
                filterCount = UserDefaults.standard.filter(definition).count
            }
        }
        .onReceive(dataSourceUpdatedPub) { _ in
            if let definition = filterViewModel.dataSource?.definition {
                filterCount = UserDefaults.standard.filter(definition).count
            }
        }
        .background {
            DataSourceFilter(filterViewModel: filterViewModel, showBottomSheet: $filterOpen)
        }
        .sheet(isPresented: $sortOpen) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if let definition = filterViewModel.dataSource?.definition {
                            SortView(definition: definition)
                                .background(Color.surfaceColor)
                        }

                        Spacer()
                    }

                }
                .navigationTitle("\(filterViewModel.dataSource?.definition.name ?? "") Sort")
                .navigationBarTitleDisplayMode(.inline)
                .background(Color.backgroundColor)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(
                            action: {
                                sortOpen.toggle()
                            },
                            label: {
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(Color.onPrimaryColor.opacity(0.87))
                            }
                        )
                        .accessibilityElement()
                        .accessibilityLabel("Close Sort")
                    }
                }
                .presentationDetents([.large])
            }
            .onAppear {
                if let definition = filterViewModel.dataSource?.definition {
                    Metrics.shared.dataSourceSort(dataSource: definition)
                }
            }
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

    @ViewBuilder
    func sortButton() -> some View {
        Button(
            action: {
                sortOpen.toggle()
            },
            label: {
                Image(systemName: "arrow.up.arrow.down")
                    .imageScale(.large)
                    .foregroundColor(Color.onPrimaryColor)
            }
        )
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Sort")
    }
}

//
//  DynamicListView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/22/22.
//

import SwiftUI
import CoreData

struct MSIListView<T: NSManagedObject & DataSourceViewBuilder>: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State var sortOpen: Bool = false
    
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String? = nil
    @State var filterOpen: Bool = false
    var filterPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Data?>
    var sortPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Data?>
    
    var watchFocusedItem: Bool = false
    
    init(focusedItem: ItemWrapper, watchFocusedItem: Bool = false, filterPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Data?>, sortPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Data?>) {
        self.focusedItem = focusedItem
        self.watchFocusedItem = watchFocusedItem
        self.filterPublisher = filterPublisher
        self.sortPublisher = sortPublisher
    }
    
    var body: some View {
        ZStack {
            if watchFocusedItem, let focusedAsam = focusedItem.dataSource as? T {
                NavigationLink(tag: "detail", selection: $selection) {
                    focusedAsam.detailView
                        .onDisappear {
                            focusedItem.dataSource = nil
                        }
                } label: {
                    EmptyView().hidden()
                }
                
                .isDetailLink(false)
                .onAppear {
                    selection = "detail"
                }
                .onChange(of: focusedItem.date) { newValue in
                    if watchFocusedItem, let _ = focusedItem.dataSource as? T {
                        selection = "detail"
                    }
                }
                
            }
            GenericSectionedList<T>(filterPublisher: filterPublisher, sortPublisher: sortPublisher)
        }
        .modifier(FilterButton(filterOpen: $filterOpen, sortOpen: $sortOpen, dataSources: Binding.constant([DataSourceItem(dataSource: T.self)])))
        .bottomSheet(isPresented: $filterOpen, detents: .large) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    FilterView(dataSource: T.self)
                        .background(Color.surfaceColor)
                    
                    Spacer()
                }
                
            }
            .navigationTitle("\(T.dataSourceName) Filters")
            .background(Color.backgroundColor)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        filterOpen.toggle()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(Color.onPrimaryColor.opacity(0.87))
                    }
                }
            }
        }
        .bottomSheet(isPresented: $sortOpen, detents: .large) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SortView(dataSource: T.self)
                        .background(Color.surfaceColor)
                    
                    Spacer()
                }
                
            }
            .navigationTitle("\(T.dataSourceName) Sort")
            .background(Color.backgroundColor)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        sortOpen.toggle()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(Color.onPrimaryColor.opacity(0.87))
                    }
                }
            }
        }
    }
}

struct GenericSectionedList<T: NSManagedObject & DataSourceViewBuilder>: View {
    @StateObject var itemsViewModel: MSIListViewModel<T>
    @State var tappedItem: T?
    @State private var showDetail = false

    var body: some View {
        ZStack {
            NavigationLink(destination: AnyView(tappedItem?.detailView), isActive: self.$showDetail) {
                EmptyView()
            }.hidden()
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    ForEach(itemsViewModel.sections, id: \.id) { section in
                        Section(header: HStack {
                            Text(section.name)
                                .overline()
                                .padding([.leading, .trailing], 8)
                                .padding(.top, 12)
                                .padding(.bottom, 4)
                            Spacer()
                        }
                            .background(Color.backgroundColor)) {
                                ForEach(section.items) { item in
                                    
                                    ZStack {
                                        NavigationLink(destination: item.detailView) {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                        
                                        HStack {
                                            item.summaryView(showMoreDetails: false, showSectionHeader: false)
                                        }
                                        .padding(.all, 16)
                                        .card()
                                    }
                                    .padding(.all, 8)
                                    .onTapGesture {
                                        tappedItem = item
                                        showDetail.toggle()
                                    }
                                }
                                .dataSourceSummaryItem()
                            }
                            .onAppear {
                                if section.id == itemsViewModel.sections[itemsViewModel.sections.count - 1].id {
                                    itemsViewModel.update(for: section.id + 1)
                                }
                            }
                    }
                }
            }
            .navigationTitle(T.dataSourceName)
            .navigationBarTitleDisplayMode(.inline)
            .dataSourceSummaryList()
        }
    }
    
    init(filterPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Data?>, sortPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Data?>) {
        _itemsViewModel = StateObject(wrappedValue: MSIListViewModel<T>(filterPublisher: filterPublisher, sortPublisher: sortPublisher))
    }
}

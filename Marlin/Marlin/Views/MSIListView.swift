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
    
    var sortDescriptors: [NSSortDescriptor] = []
    @State var filters: [DataSourceFilterParameter] = []
    @State var filterCount: Int = 0
    
    @State var sortOpen: Bool = false
    
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String? = nil
    @State var filterOpen: Bool = false
    var userDefaultsShowPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Data?>
    
    var watchFocusedItem: Bool = false
    var sectionKeyPath: KeyPath<T, String>? = nil
    
    init(focusedItem: ItemWrapper, watchFocusedItem: Bool = false, filterPublisher: NSObject.KeyValueObservingPublisher<UserDefaults, Data?>, sectionKeyPath: KeyPath<T, String>? = nil) {
        self.sortDescriptors = T.defaultSort
        self.focusedItem = focusedItem
        self.watchFocusedItem = watchFocusedItem
        self.userDefaultsShowPublisher = filterPublisher
        self.sectionKeyPath = sectionKeyPath
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
            if let sectionKeyPath = sectionKeyPath {
                GenericSectionedList<T>(filters: filters, sortDescriptors: sortDescriptors, keyPath: sectionKeyPath)
            } else {
                GenericList<T>(filters: filters, sortDescriptors: sortDescriptors)
            }
            
        }
        .modifier(FilterButton(filterOpen: $filterOpen, sortOpen: $sortOpen, dataSources: Binding.constant([DataSourceItem(dataSource: T.self)])))
        .bottomSheet(isPresented: $filterOpen, detents: .large) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    FilterView(dataSource: T.self)
                        .padding(.trailing, 16)
                        .background(Color.surfaceColor)
                    
                    Spacer()
                }
                
            }
            .navigationTitle("\(T.dataSourceName) Filters")
            .background(Color.backgroundColor)
        }
        .bottomSheet(isPresented: $sortOpen, detents: .large) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    SortView(dataSource: T.self)
                        .padding(.trailing, 16)
                        .background(Color.surfaceColor)
                    
                    Spacer()
                }
                
            }
            .navigationTitle("\(T.dataSourceName) Sort")
            .background(Color.backgroundColor)
        }
        .onReceive(userDefaultsShowPublisher) { output in
            guard let output = output else {
                return
            }
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()
                
                // Decode Note
                let filter = try decoder.decode([DataSourceFilterParameter].self, from: output)
                self.filters = filter
                self.filterCount = filters.count
            } catch {
                print("Unable to Decode Notes (\(error))")
            }
        }
    }
}

struct GenericList<T: NSManagedObject & DataSourceViewBuilder>: View {
    // That will store our fetch request, so that we can loop over it inside the body.
    // However, we don’t create the fetch request here, because we still don’t know what we’re searching for.
    // Instead, we’re going to create custom initializer(s) that accepts filtering information to set the fetchRequest property.
    @FetchRequest var fetchRequest: FetchedResults<T>
    
    var body: some View {
        List {
            ForEach(fetchRequest) { (asam: DataSourceViewBuilder) in
                ZStack {
                    NavigationLink(destination: asam.detailView
                    ) {
                        EmptyView()
                    }
                    .opacity(0)
                    
                    HStack {
                        asam.summaryView(showMoreDetails: false, showSectionHeader: false)
                    }
                    .padding(.all, 16)
                    .card()
                }
                
            }
            .dataSourceSummaryItem()
        }
        .navigationTitle(T.dataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .dataSourceSummaryList()
    }
    
    init(filters: [DataSourceFilterParameter], sortDescriptors: [NSSortDescriptor]) {
        var predicates: [NSPredicate] = []
        
        for filter in filters {
            if let predicate = filter.toPredicate() {
                predicates.append(predicate)
            }
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        _fetchRequest = FetchRequest<T>(sortDescriptors: sortDescriptors, predicate: predicate)
    }
}

struct GenericSectionedList<T: NSManagedObject & DataSourceViewBuilder>: View {
    // That will store our fetch request, so that we can loop over it inside the body.
    // However, we don’t create the fetch request here, because we still don’t know what we’re searching for.
    // Instead, we’re going to create custom initializer(s) that accepts filtering information to set the fetchRequest property.
    @SectionedFetchRequest var fetchRequest: SectionedFetchResults<String, T>
    
    var body: some View {
        List(fetchRequest) { section in
            
            Section(header: HStack {
                Text(section.id)
                    .overline()
            }) {
                ForEach(section) { item in
                    
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
                    
                }
                .dataSourceSummaryItem()
            }
        }
        .navigationTitle(T.dataSourceName)
        .navigationBarTitleDisplayMode(.inline)
        .dataSourceSummaryList()
    }
    
    init(filters: [DataSourceFilterParameter], sortDescriptors: [NSSortDescriptor], keyPath: KeyPath<T, String>) {
        var predicates: [NSPredicate] = []
        
        for filter in filters {
            if let predicate = filter.toPredicate() {
                predicates.append(predicate)
            }
        }
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        _fetchRequest = SectionedFetchRequest(sectionIdentifier: keyPath, sortDescriptors: sortDescriptors, predicate: predicate)
    }
}

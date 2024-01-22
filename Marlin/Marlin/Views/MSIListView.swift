//
//  DynamicListView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/22/22.
//

import SwiftUI
import CoreData

extension MSIListView where SectionHeader == EmptyView, Content == EmptyView, EmptyContent == EmptyView {
    init(
         focusedItem: ItemWrapper = ItemWrapper(),
         watchFocusedItem: Bool = false,
         allowUserSort: Bool = true,
         allowUserFilter: Bool = true,
         sectionHeaderIsSubList: Bool = false,
         sectionGroupNameBuilder: ((MSISection<T>) -> String)? = nil,
         sectionNameBuilder: ((MSISection<T>) -> String)? = nil
    ) {
        self.init(
            focusedItem: focusedItem,
            watchFocusedItem: watchFocusedItem,
            allowUserSort: allowUserSort,
            allowUserFilter: allowUserFilter,
            sectionHeaderIsSubList: sectionHeaderIsSubList,
            sectionGroupNameBuilder: sectionGroupNameBuilder,
            sectionNameBuilder: sectionNameBuilder,
            sectionViewBuilder: { _ in EmptyView() },
            content: { _ in EmptyView() },
            emptyView: { EmptyView() })
    }
}

extension MSIListView where Content == EmptyView, EmptyContent == EmptyView {
    init(
         focusedItem: ItemWrapper = ItemWrapper(),
         watchFocusedItem: Bool = false,
         allowUserSort: Bool = true,
         allowUserFilter: Bool = true,
         sectionHeaderIsSubList: Bool = false,
         sectionGroupNameBuilder: ((MSISection<T>) -> String)? = nil,
         sectionNameBuilder: ((MSISection<T>) -> String)? = nil,
         @ViewBuilder sectionViewBuilder: @escaping (MSISection<T>) -> SectionHeader) {
        self.init(
            focusedItem: focusedItem,
            watchFocusedItem: watchFocusedItem,
            allowUserSort: allowUserSort,
            allowUserFilter: allowUserFilter,
            sectionHeaderIsSubList: sectionHeaderIsSubList,
            sectionGroupNameBuilder: sectionGroupNameBuilder,
            sectionNameBuilder: sectionNameBuilder,
            sectionViewBuilder: sectionViewBuilder,
            content: { _ in EmptyView() },
            emptyView: { EmptyView() })
    }
}

struct MSIListView<
    T: BatchImportable & DataSourceViewBuilder,
        SectionHeader: View,
        Content: View,
        EmptyContent: View>: View {
    @EnvironmentObject var router: MarlinRouter
    @State var sortOpen: Bool = false
    
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String?
    @State var filterOpen: Bool = false

    var allowUserSort: Bool = true
    var allowUserFilter: Bool = true
    var sectionHeaderIsSubList: Bool = false
    var filterViewModel: FilterViewModel
    
    var watchFocusedItem: Bool = false
    
    var sectionGroupNameBuilder: ((MSISection<T>) -> String)?
    var sectionNameBuilder: ((MSISection<T>) -> String)?
    let sectionViewBuilder: ((MSISection<T>) -> SectionHeader)
    
    let content: ((MSISection<T>) -> Content)
    let emptyView: (() -> EmptyContent)
    
    init(
         focusedItem: ItemWrapper = ItemWrapper(),
         watchFocusedItem: Bool = false,
         allowUserSort: Bool = true,
         allowUserFilter: Bool = true,
         sectionHeaderIsSubList: Bool = false,
         sectionGroupNameBuilder: ((MSISection<T>) -> String)? = nil,
         sectionNameBuilder: ((MSISection<T>) -> String)? = nil,
         @ViewBuilder sectionViewBuilder: @escaping (MSISection<T>) -> SectionHeader,
         @ViewBuilder content: @escaping (MSISection<T>) -> Content,
         @ViewBuilder emptyView: @escaping () -> EmptyContent) {
        self.focusedItem = focusedItem
        self.watchFocusedItem = watchFocusedItem
        self.allowUserSort = allowUserSort
        self.allowUserFilter = allowUserFilter
        self.sectionHeaderIsSubList = sectionHeaderIsSubList
        self.sectionGroupNameBuilder = sectionGroupNameBuilder
        self.sectionNameBuilder = sectionNameBuilder
        self.sectionViewBuilder = sectionViewBuilder
        self.content = content
        self.filterViewModel = PersistedFilterViewModel(dataSource: DataSources.filterableFromDefintion(T.definition))
        self.emptyView = emptyView
    }
    
    var body: some View {
        Self._printChanges()
        return ZStack(alignment: .bottomTrailing) {
            GenericSectionedList<T, SectionHeader, Content, EmptyContent>(
                sectionHeaderIsSubList: sectionHeaderIsSubList,
                sectionGroupNameBuilder: sectionGroupNameBuilder,
                sectionNameBuilder: sectionNameBuilder,
                sectionViewBuilder: sectionViewBuilder,
                content: content,
                emptyView: emptyView)
            if T.self as? GeoPackageExportable.Type != nil, 
                let filterable = DataSources.filterableFromDefintion(T.definition) {
                GeoPackageExportButton(filterable: filterable)
            }
        }
        .navigationTitle(T.definition.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if watchFocusedItem, let focusedItem = focusedItem.dataSource as? T {
                router.path.append(MarlinRoute.dataSourceDetail(dataSourceKey: T.definition.key, itemKey: focusedItem.itemKey))
            }
            Metrics.shared.dataSourceList(dataSource: T.definition)
        }
        .onChange(of: focusedItem.date) { _ in
            if watchFocusedItem, let focusedItem = focusedItem.dataSource as? T {
                router.path.append(MarlinRoute.dataSourceDetail(dataSourceKey: T.definition.key, itemKey: focusedItem.itemKey))
            }
        }
        .navigationDestination(for: T.self) { item in
            item.detailView
                .onDisappear {
                    focusedItem.dataSource = nil
                }
        }
        .modifier(FilterButton(
            filterOpen: $filterOpen,
            sortOpen: $sortOpen,
            dataSources: Binding.constant([DataSourceItem(dataSource: T.self)]), 
            allowSorting: allowUserSort,
            allowFiltering: allowUserFilter))
        .background {
            DataSourceFilter(filterViewModel: filterViewModel, showBottomSheet: $filterOpen)
        }
        .sheet(isPresented: $sortOpen) {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        SortView(definition: T.definition)
                            .background(Color.surfaceColor)
                        
                        Spacer()
                    }
                    
                }
                .navigationTitle("\(T.definition.name) Sort")
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
                Metrics.shared.dataSourceSort(dataSource: T.definition)
            }
        }
        
    }
}

struct GenericSectionedList
<T: BatchImportable & DataSourceViewBuilder,
 SectionHeader: View,
    Content: View,
    EmptyContent: View>: View {
    @EnvironmentObject var router: MarlinRouter
    let sectionHeaderIsSubList: Bool
    var sectionGroupNameBuilder: ((MSISection<T>) -> String)?
    var sectionNameBuilder: ((MSISection<T>) -> String)?
    var sectionViewBuilder: ((MSISection<T>) -> SectionHeader)
    let content: ((MSISection<T>) -> Content)
    let emptyView: (() -> EmptyContent)
    
    @StateObject var itemsViewModel: MSIListViewModel<T> = MSIListViewModel<T>()
    @State var tappedItem: T?
    @State private var showDetail = false

    var body: some View {
        Group {
            if !sectionHeaderIsSubList {
                sectionHeaderList()
            } else if sectionGroupNameBuilder != nil {
                sectionHeaderGroupedSublist()
            } else {
                sectionHeaderSublist()
            }
        }
        .emptyPlaceholder(itemsViewModel.fetchedResultsController?.fetchedObjects ?? [], emptyView)
    }
    
    var groups: [String: [MSISection<T>]] {
        return Dictionary(grouping: itemsViewModel.sections) { section in
            sectionGroupNameBuilder?(section) ?? ""
        }
    }
    
    var sortedGroupIds: [String] {
        return groups.keys.sorted {
            return Int($0) ?? -1 > Int($1) ?? -1
        }.compactMap { $0 }
    }
    
    @ViewBuilder
    func sectionHeaderGroupedSublist() -> some View {
        List {
            ForEach(Array(sortedGroupIds), id: \.self) { groupKey in
                Section(header:
                            Text(groupKey)
                    .background(Color.backgroundColor)
                ) {
                    if let group = groups[groupKey] {
                        ForEach(group, id: \.id) { section in
                            NavigationLink {
                                if Content.self != EmptyView.self {
                                    content(section)
                                } else {
                                    ScrollView {
                                        LazyVStack(alignment: .leading, spacing: 0) {
                                            itemList(items: section.items)
                                        }
                                    }
                                    .background(Color.backgroundColor)
                                    .navigationTitle(sectionNameBuilder?(section) ?? section.name)
                                    .navigationBarTitleDisplayMode(.inline)
                                }
                            } label: {
                                if SectionHeader.self != EmptyView.self {
                                    sectionViewBuilder(section)
                                } else {
                                    HStack(spacing: 16) {
                                        VStack(alignment: .leading) {
                                            Text(sectionNameBuilder?(section) ?? section.name)
                                                .primary()
                                        }
                                    }
                                    .padding(.top, 8)
                                    .padding(.bottom, 8)
                                }
                            }
                            
                            .onAppear {
                                if section.id == itemsViewModel.sections[itemsViewModel.sections.count - 1].id {
                                    itemsViewModel.update(for: section.id + 1)
                                }
                            }
                        }
                    }
                }
            }
        }
        .dataSourceSummaryList()
    }
    
    @ViewBuilder
    func sectionHeaderSublist() -> some View {
        List {
            ForEach(itemsViewModel.sections, id: \.id) { section in
                NavigationLink {
                    if Content.self != EmptyView.self {
                        content(section)
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 0) {
                                itemList(items: section.items)
                            }
                        }
                        .background(Color.backgroundColor)
                        .navigationTitle(sectionNameBuilder?(section) ?? section.name)
                        .navigationBarTitleDisplayMode(.inline)
                    }
                } label: {
                    if SectionHeader.self != EmptyView.self {
                        sectionViewBuilder(section)
                    } else {
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                Text(sectionNameBuilder?(section) ?? section.name)
                                    .primary()
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    }
                }
                .onAppear {
                    if section.id == itemsViewModel.sections[itemsViewModel.sections.count - 1].id {
                        itemsViewModel.update(for: section.id + 1)
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    @ViewBuilder
    func sectionHeaderList() -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(itemsViewModel.sections, id: \.id) { section in
                    Section(header:
                        Group {
                            if section.name == "All" {
                                EmptyView()
                            } else if SectionHeader.self != EmptyView.self {
                                sectionViewBuilder(section)
                            } else {
                                HStack {
                                    Text(sectionNameBuilder?(section) ?? section.name)
                                        .overline()
                                        .padding([.leading, .trailing], 8)
                                        .padding(.top, 12)
                                        .padding(.bottom, 4)
                                    Spacer()
                                }
                            }
                        }
                        .background(Color.backgroundColor)
                    ) {
                        itemList(items: section.items)
                    }
                    .onAppear {
                        if section.id == itemsViewModel.sections[itemsViewModel.sections.count - 1].id {
                            itemsViewModel.update(for: section.id + 1)
                        }
                    }
                    .onChange(of: itemsViewModel.lastUpdateDate) { _ in
                        if section.id == itemsViewModel.sections[itemsViewModel.sections.count - 1].id {
                            itemsViewModel.update(for: section.id + 1)
                        }
                    }
                }
            }
        }
        .dataSourceSummaryList()
    }
    
    @ViewBuilder
    func itemList(items: [T]) -> some View {
        ForEach(items) { item in
            
            ZStack {
                HStack {
                    item.summary
                        .setShowMoreDetails(false)
                        .setShowSectionHeader(false)
                        .setShowTitle(true)
                }
                .padding(.all, 16)
                .card()
            }
            .padding(.all, 8)
            .onTapGesture {
                router.path.append(MarlinRoute.dataSourceDetail(dataSourceKey: T.definition.key, itemKey: item.itemKey))
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(item.itemTitle) summary")
        }
        .dataSourceSummaryItem()
    }
}

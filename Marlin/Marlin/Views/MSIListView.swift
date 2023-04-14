//
//  DynamicListView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/22/22.
//

import SwiftUI
import CoreData

extension MSIListView where SectionHeader == EmptyView, Content == EmptyView {
    init(focusedItem: ItemWrapper = ItemWrapper(),
         watchFocusedItem: Bool = false,
         allowUserSort: Bool = true,
         allowUserFilter: Bool = true,
         sectionHeaderIsSubList: Bool = false,
         sectionGroupNameBuilder: ((MSISection<T>) -> String)? = nil,
         sectionNameBuilder: ((MSISection<T>) -> String)? = nil) {
        self.init(focusedItem: focusedItem, watchFocusedItem: watchFocusedItem, allowUserSort: allowUserSort, allowUserFilter: allowUserFilter, sectionHeaderIsSubList: sectionHeaderIsSubList, sectionGroupNameBuilder: sectionGroupNameBuilder, sectionNameBuilder: sectionNameBuilder, sectionViewBuilder: { _ in EmptyView() }, content: { _ in EmptyView() })
    }
}

extension MSIListView where Content == EmptyView {
    init(focusedItem: ItemWrapper = ItemWrapper(),
         watchFocusedItem: Bool = false,
         allowUserSort: Bool = true,
         allowUserFilter: Bool = true,
         sectionHeaderIsSubList: Bool = false,
         sectionGroupNameBuilder: ((MSISection<T>) -> String)? = nil,
         sectionNameBuilder: ((MSISection<T>) -> String)? = nil,
         @ViewBuilder sectionViewBuilder: @escaping (MSISection<T>) -> SectionHeader) {
        self.init(focusedItem: focusedItem, watchFocusedItem: watchFocusedItem, allowUserSort: allowUserSort, allowUserFilter: allowUserFilter, sectionHeaderIsSubList: sectionHeaderIsSubList, sectionGroupNameBuilder: sectionGroupNameBuilder, sectionNameBuilder: sectionNameBuilder, sectionViewBuilder: sectionViewBuilder, content: { _ in EmptyView() })
    }
}

struct MSIListView<T: BatchImportable & DataSourceViewBuilder, SectionHeader: View, Content: View>: View {
    @State var sortOpen: Bool = false
    
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String? = nil
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
    
    init(focusedItem: ItemWrapper = ItemWrapper(),
         watchFocusedItem: Bool = false,
         allowUserSort: Bool = true,
         allowUserFilter: Bool = true,
         sectionHeaderIsSubList: Bool = false,
         sectionGroupNameBuilder: ((MSISection<T>) -> String)? = nil,
         sectionNameBuilder: ((MSISection<T>) -> String)? = nil,
         @ViewBuilder sectionViewBuilder: @escaping (MSISection<T>) -> SectionHeader,
         @ViewBuilder content: @escaping (MSISection<T>) -> Content) {
        self.focusedItem = focusedItem
        self.watchFocusedItem = watchFocusedItem
        self.allowUserSort = allowUserSort
        self.allowUserFilter = allowUserFilter
        self.sectionHeaderIsSubList = sectionHeaderIsSubList
        self.sectionGroupNameBuilder = sectionGroupNameBuilder
        self.sectionNameBuilder = sectionNameBuilder
        self.sectionViewBuilder = sectionViewBuilder
        self.content = content
        self.filterViewModel = FilterViewModel(dataSource: T.self)
    }
    
    var body: some View {
        ZStack {
            if watchFocusedItem, let focusedDataSource = focusedItem.dataSource as? T {
                NavigationLink(tag: "detail", selection: $selection) {
                    focusedDataSource.detailView
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
            GenericSectionedList<T, SectionHeader, Content>(sectionHeaderIsSubList: sectionHeaderIsSubList, sectionGroupNameBuilder: sectionGroupNameBuilder, sectionNameBuilder: sectionNameBuilder, sectionViewBuilder: sectionViewBuilder, content: content)
                .onAppear {
                    Metrics.shared.dataSourceList(dataSource: T.self)
                }
        }
        .modifier(FilterButton(filterOpen: $filterOpen, sortOpen: $sortOpen, dataSources: Binding.constant([DataSourceItem(dataSource: T.self)]), allowSorting: allowUserSort, allowFiltering: allowUserFilter))
        .bottomSheet(isPresented: $filterOpen, detents: .large) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    FilterView(viewModel: filterViewModel)
                        .padding(.trailing, 16)
                        .padding(.top, 8)
                        .background(Color.surfaceColor)
                    
                }
                .background(Color.surfaceColor)
                
                Spacer()
                    .foregroundColor(Color.backgroundColor)
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
                    .accessibilityElement()
                    .accessibilityLabel("Close Filter")
                }
            }
            .onAppear {
                Metrics.shared.dataSourceFilter(dataSource: T.self)
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
                    .accessibilityElement()
                    .accessibilityLabel("Close Sort")
                }
            }
            .onAppear {
                Metrics.shared.dataSourceSort(dataSource: T.self)
            }
        }
    }
}

struct GenericSectionedList<T: BatchImportable & DataSourceViewBuilder, SectionHeader: View, Content: View>: View {
    @StateObject var itemsViewModel: MSIListViewModel<T>
    @State var tappedItem: T?
    @State private var showDetail = false
    var sectionGroupNameBuilder: ((MSISection<T>) -> String)?
    var sectionNameBuilder: ((MSISection<T>) -> String)?
    var sectionViewBuilder: ((MSISection<T>) -> SectionHeader)
    let sectionHeaderIsSubList: Bool
    let content: ((MSISection<T>) -> Content)

    var body: some View {
        ZStack {
            NavigationLink(destination: AnyView(tappedItem?.detailView), isActive: self.$showDetail) {
                EmptyView()
            }.hidden()
                if !sectionHeaderIsSubList {
                    sectionHeaderList()
                } else if sectionGroupNameBuilder != nil {
                    sectionHeaderGroupedSublist()
                } else {
                    sectionHeaderSublist()
                }
            }
            
        .navigationTitle(T.fullDataSourceName)
        .navigationBarTitleDisplayMode(.inline)
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
                    .onChange(of: itemsViewModel.lastUpdateDate) { date in
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
            .accessibilityElement(children: .contain)
            .accessibilityLabel("\(item.itemTitle) summary")
        }
        .dataSourceSummaryItem()
    }
    
    init(sectionHeaderIsSubList: Bool = false,
         sectionGroupNameBuilder: ((MSISection<T>) -> String)? = nil,
         sectionNameBuilder: ((MSISection<T>) -> String)? = nil,
         @ViewBuilder sectionViewBuilder: @escaping (MSISection<T>) -> SectionHeader,
         @ViewBuilder content: @escaping (MSISection<T>) -> Content) {
        _itemsViewModel = StateObject(wrappedValue: MSIListViewModel<T>())
        self.sectionGroupNameBuilder = sectionGroupNameBuilder
        self.sectionNameBuilder = sectionNameBuilder
        self.sectionViewBuilder = sectionViewBuilder
        self.sectionHeaderIsSubList = sectionHeaderIsSubList
        self.content = content
    }
}

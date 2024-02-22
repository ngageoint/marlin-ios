//
//  DataSourceList.swift
//  Marlin
//
//  Created by Daniel Barela on 8/12/22.
//

import Foundation
import SwiftUI
import Combine
import CoreData

class DataSourceList: ObservableObject {
    let tabItems: [DataSourceItem] = [
        DataSourceItem(dataSource: DataSources.asam),
        DataSourceItem(dataSource: DataSources.modu),
        DataSourceItem(dataSource: DataSources.light),
        DataSourceItem(dataSource: DataSources.navWarning),
        DataSourceItem(dataSource: DataSources.port),
        DataSourceItem(dataSource: DataSources.radioBeacon),
        DataSourceItem(dataSource: DataSources.dgps),
        DataSourceItem(dataSource: DataSources.epub),
        DataSourceItem(dataSource: DataSources.noticeToMariners),
        DataSourceItem(dataSource: DataSources.bookmark),
        DataSourceItem(dataSource: DataSources.route)
    ]
    
    var enabledTabs: [DataSourceItem] {
        return tabItems.filter({ item in
            item.enabled
        })
    }
    
    var mappableDataSources: [DataSourceItem] {
        return enabledTabs.filter { item in
            item.dataSource.mappable
        }.sorted(by: { one, two in
            return one.order < two.order
        })
    }
    
    var allTabs: [DataSourceItem] {
        return enabledTabs.sorted(by: { one, two in
            return one.order < two.order
        })
    }
    @Published var tabs: [DataSourceItem] = []
    @Published var nonTabs: [DataSourceItem] = []
    @Published var mappedDataSources: [DataSourceItem] = []
    
    @Published var mappedFilterableDataSources: [Filterable] = []
    static let MAX_TABS = 4
    @AppStorage("userTabs") var userTabs: Int = MAX_TABS
    
    var cancellable = Set<AnyCancellable>()
    
    init() {
        _tabs = Published(initialValue: Array(allTabs.prefix(userTabs).filter({ item in
            UserDefaults.standard.dataSourceEnabled(item.dataSource)
        })))
        _nonTabs = Published(initialValue: Array(allTabs.dropFirst(userTabs).filter({ item in
            UserDefaults.standard.dataSourceEnabled(item.dataSource)
        })))
        _mappedDataSources = Published(initialValue: Array(allTabs.filter({ item in
            // no filtering Navigational Warnings for right now..
            UserDefaults.standard
                .dataSourceEnabled(item.dataSource)
            && UserDefaults.standard
                .showOnMap(key: item.key)
        })))
        
        _mappedFilterableDataSources = Published(initialValue: Array(
            allTabs.filter({ item in
                // no filtering Navigational Warnings for right now..
                UserDefaults.standard
                    .dataSourceEnabled(item.dataSource)
                && UserDefaults.standard
                    .showOnMap(key: item.key)
            })
            .compactMap({ item in
                return item.dataSource.filterable
            })
            .sorted(by: { filterable1, filterable2 in
                filterable1.definition.order < filterable2.definition.order
            })
        ))
        
        setupMappedDataSourcesUpdatedNotification()
    }

    func setupMappedDataSourcesUpdatedNotification() {
        NotificationCenter.default.publisher(for: .MappedDataSourcesUpdated)
            .sink(receiveValue: { [weak self] _ in
                guard let allTabs = self?.allTabs else {
                    return
                }
                self?._mappedDataSources = Published(
                    initialValue: Array(
                        allTabs.filter({ item in
                            UserDefaults.standard.dataSourceEnabled(item.dataSource) &&
                            UserDefaults.standard.showOnMap(key: item.key)
                        }
                                      )
                    )
                )
                self?._mappedFilterableDataSources = Published(
                    initialValue: Array(
                        allTabs.filter({ item in
                            // no filtering Navigational Warnings for right now..
                            UserDefaults.standard.dataSourceEnabled(item.dataSource) &&
                            UserDefaults.standard.showOnMap(key: item.key)
                        }
                                      )
                        .compactMap({ item in
                            DataSourceDefinitions.filterableFromDefintion(item.dataSource)
                        }
                                   )
                    )
                )
                self?.objectWillChange.send()
            })
            .store(in: &cancellable)
    }

    func addItemToTabs(dataSourceItem: DataSourceItem, position: Int) {
        nonTabs.removeAll { item in
            item == dataSourceItem
        }
        // set the order of the dropped
        tabs.insert(dataSourceItem, at: position)
        
        // reorder the tab datasources
        for i in 0...(tabs.count - 1) {
            tabs[i].order = i
        }
        
        if let last = tabs.last {
            
            // if they are above max tabs move the last tab to the non tabs
            if tabs.count > DataSourceList.MAX_TABS {
                tabs.removeLast()
                nonTabs.insert(last, at: 0)
            }
            
            // reorder the non tabs
            if nonTabs.count > 0 {
                for i in 0...nonTabs.count - 1 {
                    nonTabs[i].order = i + tabs.count
                }
            }
        }
        userTabs = tabs.count
    }
    
    func addItemToNonTabs(dataSourceItem: DataSourceItem, position: Int) {
        // remove the data source from the tab list
        tabs.removeAll { item in
            item == dataSourceItem
        }
        
        // put the data source into the non tab list where they dropped it
        nonTabs.insert(dataSourceItem, at: position)
        
        // reorder everything
        if tabs.count > 0 {
            for i in 0...tabs.count - 1 {
                tabs[i].order = i
            }
        }
        
        if nonTabs.count > 0 {
            for i in 0...nonTabs.count - 1 {
                nonTabs[i].order = i + tabs.count
            }
        }
        
        userTabs = tabs.count
    }
}

class DataSourceItem: ObservableObject, Identifiable, Hashable, Equatable {
    
    static func == (lhs: DataSourceItem, rhs: DataSourceItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    var id: String { key }
    var key: String { dataSource.key }
    var dataSource: any DataSourceDefinition

    @AppStorage<Int> var order: Int
    @AppStorage<Bool> var showOnMap: Bool {
        didSet {
            NotificationCenter.default.post(name: .MappedDataSourcesUpdated, object: nil)
        }
    }
    @AppStorage<Data> var filterData: Data {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    @AppStorage<Bool> var enabled: Bool
    
    init(dataSource: any DataSourceDefinition) {
        self.dataSource = dataSource
        self._order = AppStorage(
            wrappedValue: 0,
            "\(dataSource.key)Order")
        self._showOnMap = AppStorage(
            wrappedValue: dataSource.mappable,
            "showOnMap\(dataSource.key)")
        self._filterData = AppStorage(
            wrappedValue: Data(),
            "\(dataSource.key)Filter")
        self._enabled = AppStorage(
            wrappedValue: UserDefaults.standard.dataSourceEnabled(dataSource),
            "\(dataSource.key)DataSourceEnabled")

    }
    
    var description: String {
        return "Data Source \(key) order: \(order)"
    }
}

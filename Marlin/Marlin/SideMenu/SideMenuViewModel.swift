//
//  SideMenuViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 2/3/23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

class SideMenuViewModel: ObservableObject {
    @Published var dataSourceList: DataSourceList
    
    @Published var draggedItem : String?
    @Published var validDropTarget: Bool = false
    @Published var lastTab: DataSourceItem?
    
    @AppStorage("userTabs") var userTabs: Int = 3
    
    init(dataSourceList: DataSourceList) {
        self.dataSourceList = dataSourceList
    }
    
    func onDrag(dataSource: DataSourceItem) -> NSItemProvider {
        if !dataSourceList.tabs.isEmpty {
            lastTab = dataSourceList.tabs[dataSourceList.tabs.count - 1]
        }
        draggedItem = dataSource.key
        return NSItemProvider(object: dataSource.key as NSString)
    }
    
    // this will never happen for now, but in case we allow users to hide data sources completely from the interface, it might
    func dropOnEmptyNonTabFirst(items: [NSItemProvider]) -> Bool {
        for item in items {
            _ = item.loadObject(ofClass: String.self) { droppedString, _ in
                // grab the data source
                let ds = self.dataSourceList.tabs.first { item in
                    item.key == droppedString
                }
                
                if let ds = ds {
                    DispatchQueue.main.async {
                        self.dataSourceList.addItemToNonTabs(dataSourceItem: ds, position: 0)
                    }
                }
            }
        }
        draggedItem = nil
        validDropTarget = false
        return true
    }
    
    func dropOnEmptyTabFirst(items: [NSItemProvider]) -> Bool {
        for item in items {
            _ = item.loadObject(ofClass: NSString.self) { droppedString, _ in
                // grab the data source
                let ds = self.dataSourceList.nonTabs.first { item in
                    item.key == droppedString as? String
                }
                
                if let ds = ds {
                    DispatchQueue.main.async {
                        self.dataSourceList.addItemToTabs(dataSourceItem: ds, position: 0)
                    }
                }
            }
        }
        draggedItem = nil
        validDropTarget = false
        return true
    }
    
    func validateDrop() -> Bool {
        guard draggedItem != nil else {
            return false
        }
        
        validDropTarget = true
        return true
    }
    
    func performDrop() -> Bool {
        draggedItem = nil
        
        if dataSourceList.tabs.count > DataSourceList.MAX_TABS {
            let ds = dataSourceList.tabs.removeLast()
            
            let to = dataSourceList.nonTabs.startIndex
            dataSourceList.nonTabs.insert(ds, at: to)
        }
        
        if dataSourceList.tabs.count > 0 {
            for i in 0...(dataSourceList.tabs.count - 1) {
                dataSourceList.tabs[i].order = i
            }
        }
        if dataSourceList.nonTabs.count > 0 {
            for i in 0...(dataSourceList.nonTabs.count - 1) {
                dataSourceList.nonTabs[i].order = i + dataSourceList.tabs.count
            }
        }
        userTabs = dataSourceList.tabs.count
        return true
    }
    
    func dropEntered(item: DataSourceItem) {
        guard let draggedItem = draggedItem else {
            return
        }
        // if this item is the one being dragged, ignore
        if draggedItem == item.key {
            return
        }
        
        // if this item is a tab
        if dataSourceList.tabs.contains(item) {
            let isDraggedItemATab = dataSourceList.tabs.contains { item in
                item.key == draggedItem
            }
            
            // if the dragged item is also a tab, reorder
            if isDraggedItemATab {
                let from = dataSourceList.tabs.firstIndex { item in
                    item.key == draggedItem
                }
                let to = dataSourceList.tabs.firstIndex(of: item)
                
                if let from = from, let to = to {
                    withAnimation(.default) {
                        self.dataSourceList.tabs.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                    }
                }
            } else {
                // if the dragged item is a non tab, remove it from the non tabs and add it to the tabs
                
                let ds = dataSourceList.nonTabs.first { item in
                    item.key == draggedItem
                }
                
                self.dataSourceList.nonTabs.removeAll { item in
                    item.key == draggedItem
                }
                let to = dataSourceList.tabs.firstIndex(of: item)
                if let to = to, let ds = ds {
                    self.dataSourceList.tabs.insert(ds, at: to)
                }
                
                // if there are too many tabs
                if dataSourceList.tabs.count > DataSourceList.MAX_TABS {
                    let ds = dataSourceList.tabs.removeLast()
                    
                    let to = dataSourceList.nonTabs.startIndex
                    dataSourceList.nonTabs.insert(ds, at: to)
                }
            }
        } else {
            // if this item is a non tab
            
            let isDraggedItemANonTab = dataSourceList.nonTabs.contains { item in
                item.key == draggedItem
            }
            
            // if the dragged item is also a non tab, reorder
            if isDraggedItemANonTab {
                let from = dataSourceList.nonTabs.firstIndex { item in
                    item.key == draggedItem
                }
                let to = dataSourceList.nonTabs.firstIndex(of: item)
                
                if let from = from, let to = to {
                    withAnimation(.default) {
                        dataSourceList.nonTabs.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                    }
                }
            } else {
                // if the dragged item is a tab, remove it from the tabs and add it to the nontabs
                let ds = dataSourceList.tabs.first { item in
                    item.key == draggedItem
                }
                
                dataSourceList.tabs.removeAll { item in
                    item.key == draggedItem
                }
                let to = dataSourceList.nonTabs.firstIndex(of: item)
                if let to = to, let ds = ds {
                    dataSourceList.nonTabs.insert(ds, at: to)
                }
                
                // if the last tab had been moved out of the tab list but can now fit, put it back
                if let lastTab = lastTab, lastTab.key != draggedItem {
                    let tabIndex = dataSourceList.tabs.firstIndex(of: lastTab)
                    if dataSourceList.tabs.count < DataSourceList.MAX_TABS && tabIndex == nil {
                        dataSourceList.nonTabs.removeAll { item in
                            item.key == lastTab.key
                        }
                        dataSourceList.tabs.insert(lastTab, at: dataSourceList.tabs.endIndex)
                    }
                }
            }
        }
    }
}

struct SideMenuDrop: DropDelegate {
    
    let item : DataSourceItem
    @ObservedObject var model: SideMenuViewModel
    
    func validateDrop(info: DropInfo) -> Bool {
        model.validateDrop()
    }
    
    func performDrop(info: DropInfo) -> Bool {
        model.performDrop()
    }
    
    func dropEntered(info: DropInfo) {
        model.dropEntered(item: item)
    }
    
}


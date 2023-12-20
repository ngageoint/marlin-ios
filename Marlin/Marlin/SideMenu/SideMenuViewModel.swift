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
    
    @Published var draggedItem: String?
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
    
    // this will never happen for now, but in case we allow users to hide data 
    // sources completely from the interface, it might
    func dropOnEmptyNonTabFirst(items: [NSItemProvider]) -> Bool {
        for item in items {
            _ = item.loadObject(ofClass: String.self) { droppedString, _ in
                // grab the data source
                let dataSource = self.dataSourceList.tabs.first { item in
                    item.key == droppedString
                }
                
                if let dataSource = dataSource {
                    DispatchQueue.main.async {
                        self.dataSourceList.addItemToNonTabs(dataSourceItem: dataSource, position: 0)
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
                let dataSource = self.dataSourceList.nonTabs.first { item in
                    item.key == droppedString as? String
                }
                
                if let dataSource = dataSource {
                    DispatchQueue.main.async {
                        self.dataSourceList.addItemToTabs(dataSourceItem: dataSource, position: 0)
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
            let dataSource = dataSourceList.tabs.removeLast()

            let toPosition = dataSourceList.nonTabs.startIndex
            dataSourceList.nonTabs.insert(dataSource, at: toPosition)
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

    func dropOnTab(item: DataSourceItem) {
        let isDraggedItemATab = dataSourceList.tabs.contains { item in
            item.key == draggedItem
        }

        // if the dragged item is also a tab, reorder
        if isDraggedItemATab {
            let from = dataSourceList.tabs.firstIndex { item in
                item.key == draggedItem
            }
            let toPosition = dataSourceList.tabs.firstIndex(of: item)

            if let from = from, let toPosition = toPosition {
                withAnimation(.default) {
                    self.dataSourceList.tabs.move(
                        fromOffsets: IndexSet(integer: from),
                        toOffset: toPosition > from ? toPosition + 1 : toPosition
                    )
                }
            }
        } else {
            // if the dragged item is a non tab, remove it from the non tabs and add it to the tabs

            let dataSource = dataSourceList.nonTabs.first { item in
                item.key == draggedItem
            }

            self.dataSourceList.nonTabs.removeAll { item in
                item.key == draggedItem
            }
            let toPosition = dataSourceList.tabs.firstIndex(of: item)
            if let toPosition = toPosition, let dataSource = dataSource {
                self.dataSourceList.tabs.insert(dataSource, at: toPosition)
            }

            // if there are too many tabs
            if dataSourceList.tabs.count > DataSourceList.MAX_TABS {
                let dataSource = dataSourceList.tabs.removeLast()

                let toPosition = dataSourceList.nonTabs.startIndex
                dataSourceList.nonTabs.insert(dataSource, at: toPosition)
            }
        }
    }

    func dropOnNonTab(item: DataSourceItem) {
        let isDraggedItemANonTab = dataSourceList.nonTabs.contains { item in
            item.key == draggedItem
        }

        // if the dragged item is also a non tab, reorder
        if isDraggedItemANonTab {
            let from = dataSourceList.nonTabs.firstIndex { item in
                item.key == draggedItem
            }
            let toPosition = dataSourceList.nonTabs.firstIndex(of: item)

            if let from = from, let toPosition = toPosition {
                withAnimation(.default) {
                    dataSourceList.nonTabs.move(
                        fromOffsets: IndexSet(integer: from),
                        toOffset: toPosition > from ? toPosition + 1 : toPosition
                    )
                }
            }
        } else {
            // if the dragged item is a tab, remove it from the tabs and add it to the nontabs
            let dataSource = dataSourceList.tabs.first { item in
                item.key == draggedItem
            }

            dataSourceList.tabs.removeAll { item in
                item.key == draggedItem
            }
            let toPosition = dataSourceList.nonTabs.firstIndex(of: item)
            if let toPosition = toPosition, let dataSource = dataSource {
                dataSourceList.nonTabs.insert(dataSource, at: toPosition)
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
            dropOnTab(item: item)
        } else {
            // if this item is a non tab
            dropOnNonTab(item: item)
        }
    }
}

struct SideMenuDrop: DropDelegate {
    
    let item: DataSourceItem
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

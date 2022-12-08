//
//  SideMenu.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct SideMenuContent: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State var isEditMode: EditMode = .active
    @State var draggedItem : String?
    @State var validDropTarget: Bool = false
    @State var lastTab: DataSourceItem?
    
    @ObservedObject var dataSourceList: DataSourceList
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Color.primaryColor
                    .frame(maxWidth: .infinity, maxHeight: 80)
                HStack {
                    Text("Data Source \(horizontalSizeClass == .compact ? "Tabs" : "Rail Items") (Drag to reorder)")
                        .padding([.leading, .top, .bottom, .trailing], 8)
                        .overline()
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.backgroundColor)
                
                if dataSourceList.tabs.count != 0 {
                    ForEach(dataSourceList.tabs, id: \.self) { dataSource in
                        DataSourceCell(dataSourceItem: dataSource)
                            .overlay(validDropTarget && draggedItem == dataSource.key ? Color.white.opacity(0.8) : Color.clear)
                            .onDrag {
                                if !dataSourceList.tabs.isEmpty {
                                    self.lastTab = dataSourceList.tabs[dataSourceList.tabs.count - 1]
                                }
                                self.draggedItem = dataSource.key
                                return NSItemProvider(object: dataSource.key as NSString)
                            }
                            .onDrop(of: [.plainText], delegate: SideMenuDrop(item: dataSource, tabItems: $dataSourceList.tabs, nonTabItems: $dataSourceList.nonTabs, draggedItem: $draggedItem, validDropTarget: $validDropTarget, lastTab: $lastTab))
                    }
                } else {
                    Text("Drag here to add a \(horizontalSizeClass == .compact ? "tabs" : "rail items")")
                        .padding([.leading, .top, .bottom, .trailing], 8)
                        .overline()
                        .frame(maxWidth: .infinity)
                        .onDrop(of: [.plainText], isTargeted: nil, perform: dropOnEmptyTabFirst)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .strokeBorder(Color.gray, style: StrokeStyle(dash: [10]))
                                .padding([.trailing, .leading], 8)
                                .background(Color.backgroundColor)
                                .onDrop(of: [.plainText], isTargeted: nil, perform: dropOnEmptyTabFirst)
                        )
                }
                HStack {
                    Text("Other Data Sources (Drag to add to \(horizontalSizeClass == .compact ? "tabs" : "rail items"))")
                        .padding([.leading, .top, .bottom, .trailing], 8)
                        .overline()
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.backgroundColor)
                
                if dataSourceList.nonTabs.count != 0 {
                    ForEach(dataSourceList.nonTabs, id: \.self) { dataSource in
                        DataSourceCell(dataSourceItem: dataSource)
                            .overlay(validDropTarget && draggedItem == dataSource.key ? Color.white.opacity(0.8) : Color.clear)
                            .onDrag {
                                if !dataSourceList.tabs.isEmpty {
                                    self.lastTab = dataSourceList.tabs[dataSourceList.tabs.count - 1]
                                }
                                self.draggedItem = dataSource.key
                                return NSItemProvider(object: dataSource.key as NSString)
                            }
                            .onDrop(of: [.plainText], delegate: SideMenuDrop(item: dataSource, tabItems: $dataSourceList.tabs, nonTabItems: $dataSourceList.nonTabs, draggedItem: $draggedItem, validDropTarget: $validDropTarget, lastTab: $lastTab))
                    }
                } else {
                    Text("Drag here to remove a \(horizontalSizeClass == .compact ? "tab" : "rail item")")
                        .padding([.leading, .top, .bottom, .trailing], 8)
                        .overline()
                        .frame(maxWidth: .infinity)
                        .onDrop(of: [.plainText], isTargeted: nil, perform: dropOnEmptyNonTabFirst)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .strokeBorder(Color.gray, style: StrokeStyle(dash: [10]))
                                .padding([.trailing, .leading], 8)
                                .background(Color.backgroundColor)
                                .onDrop(of: [.plainText], isTargeted: nil, perform: dropOnEmptyNonTabFirst)
                        )
                }
                
                HStack {
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.backgroundColor)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center) {
                        Image(systemName: "doc.fill.badge.plus")
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                        Text("Submit Report to NGA")
                            .font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.87)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        NotificationCenter.default.post(name: .SwitchTabs, object: "submitReport")
                    }
                    .padding([.leading, .top, .bottom, .trailing], 16)
                    Divider()
                }
                .background(Color.surfaceColor)
                HStack {
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.backgroundColor)
                AboutCell()
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .background(Color.backgroundColor)
            .ignoresSafeArea(.all, edges: [.top, .bottom])
            .onDrop(of: [.text], isTargeted: nil) { provider in
                draggedItem = nil
                validDropTarget = false
                return true
            }
        }
    }
    
    func dropOnEmptyNonTabFirst(items: [NSItemProvider]) -> Bool {
        for item in items {
            _ = item.loadObject(ofClass: String.self) { droppedString, _ in
                // grab the data source
                let ds = dataSourceList.tabs.first { item in
                    item.key == droppedString
                }

                if let ds = ds {
                    DispatchQueue.main.async {
                        dataSourceList.addItemToNonTabs(dataSourceItem: ds, position: 0)
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
                let ds = dataSourceList.nonTabs.first { item in
                    item.key == droppedString as? String
                }
                
                if let ds = ds {
                    DispatchQueue.main.async {
                        dataSourceList.addItemToTabs(dataSourceItem: ds, position: 0)
                    }
                }
            }
        }
        draggedItem = nil
        validDropTarget = false
        return true
    }
}

struct SideMenuDrop: DropDelegate {
    
    let item : DataSourceItem
    @Binding var tabItems : [DataSourceItem]
    @Binding var nonTabItems: [DataSourceItem]
    @Binding var draggedItem : String?
    @Binding var validDropTarget : Bool
    @Binding var lastTab: DataSourceItem?
    @AppStorage("userTabs") var userTabs: Int = 3
    
    func validateDrop(info: DropInfo) -> Bool {
        guard let draggedItem = self.draggedItem else {
            return false
        }
        
        validDropTarget = true
        return true
    }
 
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        
        if tabItems.count > DataSourceList.MAX_TABS {
            let ds = self.tabItems.removeLast()
        
            let to = nonTabItems.startIndex
            self.nonTabItems.insert(ds, at: to)
        }

        if tabItems.count > 0 {
            for i in 0...(tabItems.count - 1) {
                tabItems[i].order = i
            }
        }
        if nonTabItems.count > 0 {
            for i in 0...(nonTabItems.count - 1) {
                nonTabItems[i].order = i + tabItems.count
            }
        }
        userTabs = tabItems.count
        return true
    }
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }
        // if this item is the one being dragged, ignore
        if draggedItem == item.key {
            return
        }
        
        // if this item is a tab
        if tabItems.contains(item) {
            let isDraggedItemATab = tabItems.contains { item in
                item.key == draggedItem
            }
            
            // if the dragged item is also a tab, reorder
            if isDraggedItemATab {
                let from = tabItems.firstIndex { item in
                    item.key == draggedItem
                }
                let to = tabItems.firstIndex(of: item)
                
                if let from = from, let to = to {
                    withAnimation(.default) {
                        self.tabItems.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                    }
                }
            } else {
                // if the dragged item is a non tab, remove it from the non tabs and add it to the tabs
                
                let ds = nonTabItems.first { item in
                    item.key == draggedItem
                }
                
                self.nonTabItems.removeAll { item in
                    item.key == draggedItem
                }
                let to = tabItems.firstIndex(of: item)
                if let to = to, let ds = ds {
                    self.tabItems.insert(ds, at: to)
                }
                
                // if there are too many tabs
                if tabItems.count > DataSourceList.MAX_TABS {
                    let ds = self.tabItems.removeLast()
                    
                    let to = nonTabItems.startIndex
                    self.nonTabItems.insert(ds, at: to)
                }
            }
        } else {
            // if this item is a non tab
            
            let isDraggedItemANonTab = nonTabItems.contains { item in
                item.key == draggedItem
            }
            
            // if the dragged item is also a non tab, reorder
            if isDraggedItemANonTab {
                let from = nonTabItems.firstIndex { item in
                    item.key == draggedItem
                }
                let to = nonTabItems.firstIndex(of: item)
                
                if let from = from, let to = to {
                    withAnimation(.default) {
                        self.nonTabItems.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
                    }
                }
            } else {
                // if the dragged item is a tab, remove it from the tabs and add it to the nontabs
                let ds = tabItems.first { item in
                    item.key == draggedItem
                }
                
                self.tabItems.removeAll { item in
                    item.key == draggedItem
                }
                let to = nonTabItems.firstIndex(of: item)
                if let to = to, let ds = ds {
                    self.nonTabItems.insert(ds, at: to)
                }
                
                // if the last tab had been moved out of the tab list but can now fit, put it back
                if let lastTab = lastTab, lastTab.key != draggedItem {
                    let tabIndex = tabItems.firstIndex(of: lastTab)
                    if tabItems.count < DataSourceList.MAX_TABS && tabIndex == nil {
                        self.nonTabItems.removeAll { item in
                            item.key == lastTab.key
                        }
                        tabItems.insert(lastTab, at: tabItems.endIndex)
                    }
                }
            }
        }
    }
    
}

//struct SideMenuContent_Previews: PreviewProvider {
//    static var previews: some View {
//        SideMenuContent()
//    }
//}

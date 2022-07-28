//
//  SideMenu.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI
import UniformTypeIdentifiers

class DataSourceList: ObservableObject {
    let allTabs: [DataSourceItem] = [
        DataSourceItem(dataSource: Asam.self),
        DataSourceItem(dataSource: Modu.self),
        DataSourceItem(dataSource: Light.self),
        DataSourceItem(dataSource: NavigationalWarning.self)
    ].sorted(by: { one, two in
        return one.order < two.order
    })
    
    @Published var tabs: [DataSourceItem] = []
    @Published var nonTabs: [DataSourceItem] = []
    
    static let MAX_TABS = 4
    @AppStorage("userTabs") var userTabs: Int = MAX_TABS
    
    init() {
        _tabs = Published(initialValue: Array(allTabs.prefix(userTabs)))
        _nonTabs = Published(initialValue: Array(allTabs.dropFirst(userTabs)))
    }
    
    func addItemToTabs(dataSourceItem: DataSourceItem, position: Int) {
        nonTabs.removeAll { item in
            item == dataSourceItem
        }
        // set the order of the dropped
        tabs.insert(dataSourceItem, at: 0)
        
        // reorder the tab datasources
        for i in 0...(tabs.count - 1) {
            tabs[i].order = i
        }
        
        if let last = tabs.last {
            
            // if they are above max tabs move the last tab to the non tabs
            if tabs.count > DataSourceList.MAX_TABS{
                tabs.removeLast()
                nonTabs.insert(last, at: 0)
            }
            
            // reorder the non tabs
            if nonTabs.count > 1 {
                for i in (1)...(nonTabs.count - 1) {
                    nonTabs[i].order = last.order + i
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
    var dataSource: DataSource.Type
    
    @AppStorage<Int> var order: Int
    @AppStorage<Bool> var showOnMap: Bool

    init(dataSource: DataSource.Type) {
        self.dataSource = dataSource
        self._order = AppStorage(wrappedValue: 0, "\(dataSource.key)Order")
        self._showOnMap = AppStorage(wrappedValue: dataSource.isMappable, "showOnMap\(dataSource.key)")
    }
    
    var description: String {
        return "Data Source \(key) order: \(order)"
    }
}

struct SideMenuContent: View {
    @EnvironmentObject var scheme: MarlinScheme
    
    @State var isEditMode: EditMode = .active
    @State var draggedItem : String?
    @State var validDropTarget: Bool = false
    
    @ObservedObject var dataSourceList: DataSourceList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Color(scheme.containerScheme.colorScheme.primaryColor)
                .frame(maxWidth: .infinity, maxHeight: 80)
            HStack {
                Text("Data Source Tabs (Drag to reorder)")
                    .padding([.leading, .top, .bottom, .trailing], 8)
                    .font(Font(scheme.containerScheme.typographyScheme.overline))
                    .foregroundColor(Color(scheme.containerScheme.colorScheme.onBackgroundColor.withAlphaComponent(0.6)))
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(Color(scheme.containerScheme.colorScheme.backgroundColor))
        
            if dataSourceList.tabs.count != 0 {
                ForEach(dataSourceList.tabs, id: \.self) { dataSource in
                    DataSourceCell(dataSourceItem: dataSource)
                        .overlay(validDropTarget && draggedItem == dataSource.key ? Color.white.opacity(0.8) : Color.clear)
                        .onDrag {
                            self.draggedItem = dataSource.key
                            return NSItemProvider(object: dataSource.key as NSString)
                        }
                        .onDrop(of: [.plainText], delegate: SideMenuDrop(item: dataSource, tabItems: $dataSourceList.tabs, nonTabItems: $dataSourceList.nonTabs, draggedItem: $draggedItem, validDropTarget: $validDropTarget))
                }
            } else {
                Text("Drag here to add a tab")
                    .padding([.leading, .top, .bottom, .trailing], 8)
                    .font(Font(scheme.containerScheme.typographyScheme.overline))
                    .foregroundColor(Color(scheme.containerScheme.colorScheme.onBackgroundColor.withAlphaComponent(0.6)))
                    .frame(maxWidth: .infinity)
                    .onDrop(of: [.plainText], isTargeted: nil, perform: dropOnEmptyNonTabFirst)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(Color.gray, style: StrokeStyle(dash: [10]))
                            .padding([.trailing, .leading], 8)
                            .background(Color(scheme.containerScheme.colorScheme.backgroundColor))
                            .onDrop(of: [.plainText], isTargeted: nil, perform: dropOnEmptyTabFirst)
                    )
            }
            HStack {
                Text("Other Data Sources (Drag to add to tabs)")
                    .padding([.leading, .top, .bottom, .trailing], 8)
                    .font(Font(scheme.containerScheme.typographyScheme.overline))
                    .foregroundColor(Color(scheme.containerScheme.colorScheme.onBackgroundColor.withAlphaComponent(0.6)))
                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 8)
            .background(Color(scheme.containerScheme.colorScheme.backgroundColor))
            
            if dataSourceList.nonTabs.count != 0 {
                ForEach(dataSourceList.nonTabs, id: \.self) { dataSource in
                    DataSourceCell(dataSourceItem: dataSource)
                        .overlay(validDropTarget && draggedItem == dataSource.key ? Color.white.opacity(0.8) : Color.clear)
                        .onDrag {
                            self.draggedItem = dataSource.key
                            return NSItemProvider(object: dataSource.key as NSString)
                        }
                        .onDrop(of: [.plainText], delegate: SideMenuDrop(item: dataSource, tabItems: $dataSourceList.tabs, nonTabItems: $dataSourceList.nonTabs, draggedItem: $draggedItem, validDropTarget: $validDropTarget))
                }
            } else {
                Text("Drag here to remove a tab")
                    .padding([.leading, .top, .bottom, .trailing], 8)
                    .font(Font(scheme.containerScheme.typographyScheme.overline))
                    .foregroundColor(Color(scheme.containerScheme.colorScheme.onBackgroundColor.withAlphaComponent(0.6)))
                    .frame(maxWidth: .infinity)
                    .onDrop(of: [.plainText], isTargeted: nil, perform: dropOnEmptyNonTabFirst)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(Color.gray, style: StrokeStyle(dash: [10]))
                            .padding([.trailing, .leading], 8)
                            .background(Color(scheme.containerScheme.colorScheme.backgroundColor))
                            .onDrop(of: [.plainText], isTargeted: nil, perform: dropOnEmptyNonTabFirst)
                    )
            }
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .background(Color(scheme.containerScheme.colorScheme.backgroundColor))
        .ignoresSafeArea()
        .onDrop(of: [.text], isTargeted: nil) { provider in
            draggedItem = nil
            validDropTarget = false
            return true
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
    @AppStorage("userTabs") var userTabs: Int = 3
    
    func validateDrop(info: DropInfo) -> Bool {
        guard let draggedItem = self.draggedItem else {
            return false
        }
        
        if tabItems.contains(item) && tabItems.count >= DataSourceList.MAX_TABS && !tabItems.contains(where: { item in
            item.key == draggedItem
        }) {
            validDropTarget = false
            return false
        }
        validDropTarget = true
        return true
    }
 
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
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
        if tabItems.contains(item) && tabItems.count >= DataSourceList.MAX_TABS && !tabItems.contains(where: { item in
            item.key == draggedItem
        }) {
            return
        }
        
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
            }
        }
    }
    
}

//struct SideMenuContent_Previews: PreviewProvider {
//    static var previews: some View {
//        SideMenuContent()
//    }
//}
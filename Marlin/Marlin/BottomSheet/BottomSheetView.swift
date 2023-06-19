//
//  BottomSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation

import SwiftUI

class BottomSheetItemList: ObservableObject {
    @Published var bottomSheetItems: [BottomSheetItem]?
}

struct MarlinDataBottomSheet: View {
    @State var showBottomSheet: Bool = false
    @StateObject var itemList: BottomSheetItemList = BottomSheetItemList()

    let mapItemsTappedPub = NotificationCenter.default.publisher(for: .MapItemsTapped)
    let dismissBottomSheetPub = NotificationCenter.default.publisher(for: .DismissBottomSheet)

    var body: some View {
        
        Self._printChanges()
        return
            Color.clear
            .sheet(isPresented: $showBottomSheet, onDismiss: {
                NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: nil))
            }) {
                MarlinBottomSheet(itemList: itemList)
                    .environmentObject(LocationManager.shared())
                    .presentationDetents([.medium])
            }
            
            .onReceive(mapItemsTappedPub) { output in
                guard let notification = output.object as? MapItemsTappedNotification else {
                    return
                }
                var bottomSheetItems: [BottomSheetItem] = []
                bottomSheetItems += self.handleTappedItems(items: notification.items, mapName: notification.mapName, zoom: notification.zoom)
                if bottomSheetItems.count == 0 {
                    return
                }
                itemList.bottomSheetItems = bottomSheetItems
                showBottomSheet.toggle()
            }
            .onReceive(dismissBottomSheetPub) { output in
                showBottomSheet = false
            }
    }
    
    func handleTappedItems(items: [any DataSource]?, mapName: String?, zoom: Bool) -> [BottomSheetItem] {
        var bottomSheetItems: [BottomSheetItem] = []
        if let items = items {
            for item in items {
                let bottomSheetItem = BottomSheetItem(item: item, mapName: mapName, zoom: zoom)
                bottomSheetItems.append(bottomSheetItem)
            }
        }
        return bottomSheetItems
    }
}

struct MarlinBottomSheet: View {
    @ObservedObject var itemList: BottomSheetItemList
    @State var selectedItem: Int = 0

    var pages: Int { itemList.bottomSheetItems?.count ?? 0 }
    
    @ViewBuilder
    private var rectangle: some View {
        Rectangle()
            .fill(Color(itemList.bottomSheetItems?[selectedItem].item.color ?? .clear))
            .frame(maxWidth: 8, maxHeight: .infinity)
    }
    
    var body: some View {
        Self._printChanges()
        return
            VStack {
                ZStack {
                    if let bottomSheetItems = itemList.bottomSheetItems {
                        let item = bottomSheetItems[selectedItem].item
                        
                        if let imageName = type(of: item).imageName {
                            HStack {
                                Image(imageName)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color(item.color))
                                    .clipShape(Circle())
                                Spacer()
                            }
                        } else if let systemImageName = type(of: item).systemImageName {
                            HStack {
                                Image(systemName: systemImageName)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.white)
                                    .padding(5)
                                    .background(Color(item.color))
                                    .clipShape(Circle())
                                Spacer()
                            }
                        }
                        
                        if bottomSheetItems.count > 1 {
                            HStack(spacing: 8) {
                                Button(action: {
                                    withAnimation {
                                        selectedItem = max(0, selectedItem - 1)
                                    }
                                }) {
                                    Label(
                                        title: {},
                                        icon: { Image(systemName: "chevron.left")
                                                .renderingMode(.template)
                                                .foregroundColor(selectedItem != 0 ? Color.primaryColorVariant : Color.disabledColor)
                                        })
                                }
                                .buttonStyle(MaterialButtonStyle())
                                .accessibilityElement()
                                .accessibilityLabel("previous")
                                
                                Text("\(selectedItem + 1) of \(pages)")
                                    .font(Font.caption)
                                    .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                                
                                Button(action: {
                                    withAnimation {
                                        selectedItem = min(pages - 1, selectedItem + 1)
                                    }
                                }) {
                                    Label(
                                        title: {},
                                        icon: { Image(systemName: "chevron.right")
                                                .renderingMode(.template)
                                                .foregroundColor(pages - 1 != selectedItem ? Color.primaryColorVariant : Color.disabledColor)
                                        })
                                }
                                .buttonStyle(MaterialButtonStyle())
                                .accessibilityElement()
                                .accessibilityLabel("next")
                            }
                        }
                    }
                }
                
                if let item = itemList.bottomSheetItems?[selectedItem] {
                    if let dataSource = item.item as? DataSourceViewBuilder {
                        dataSource.summaryView(showMoreDetails: true, showSectionHeader: true, mapName: item.mapName, showTitle: true)
                            .transition(.opacity)
                    }
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .padding(.all, 16)
            .background(
                HStack {
                    rectangle
                    Spacer()
                }
                    .ignoresSafeArea()
            )
            .onChange(of: selectedItem) { item in
                if let bottomSheetItem = itemList.bottomSheetItems?[selectedItem], let item = bottomSheetItem.item as? DataSourceLocation {
                    NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: item, zoom: bottomSheetItem.zoom, mapName: bottomSheetItem.mapName))
                }
            }
            .onAppear {
                if let bottomSheetItem = itemList.bottomSheetItems?[selectedItem], let item = bottomSheetItem.item as? DataSourceLocation {
                    NotificationCenter.default.post(name: .FocusMapOnItem, object: FocusMapOnItemNotification(item: item, zoom: bottomSheetItem.zoom, mapName: bottomSheetItem.mapName))
                    Metrics.shared.dataSourceBottomSheet(dataSource: type(of: item))
                }
            }
    }
}

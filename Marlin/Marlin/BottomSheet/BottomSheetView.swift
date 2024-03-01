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
            .sheet(
                isPresented: $showBottomSheet,
                onDismiss: {
                    NotificationCenter.default.post(
                        name: .FocusMapOnItem,
                        object: FocusMapOnItemNotification(item: nil)
                    )
                },
                content: {
                    MarlinBottomSheet(itemList: itemList, focusNotification: .FocusMapOnItem)
                        .environmentObject(LocationManager.shared())
                        .presentationDetents([.medium])
                }
            )

            .onReceive(mapItemsTappedPub) { output in
                guard let notification = output.object as? MapItemsTappedNotification else {
                    return
                }
                var bottomSheetItems: [BottomSheetItem] = []
                bottomSheetItems += self.handleTappedItems(
                    items: notification.items,
                    mapName: notification.mapName,
                    zoom: notification.zoom
                )
                if bottomSheetItems.count == 0 {
                    return
                }
                itemList.bottomSheetItems = bottomSheetItems
                showBottomSheet.toggle()
            }
            .onReceive(dismissBottomSheetPub) { _ in
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

struct MarlinBottomSheet <Content: View>: View {
    @ObservedObject var itemList: BottomSheetItemList
    @State var selectedItem: Int = 0

    var pages: Int { itemList.bottomSheetItems?.count ?? 0 }
    let focusNotification: NSNotification.Name
        
    let contentBuilder: (_ item: BottomSheetItem) -> Content

    init(
        itemList: BottomSheetItemList,
        focusNotification: NSNotification.Name,
        @ViewBuilder contentBuilder: @escaping (_ item: BottomSheetItem) -> Content
    ) {
        self.itemList = itemList
        self.contentBuilder = contentBuilder
        self.focusNotification = focusNotification
    }
    init(
        itemList: BottomSheetItemList,
        focusNotification: NSNotification.Name
    ) where Content == AnyView {
        self.init(itemList: itemList, focusNotification: focusNotification) { item in
            AnyView(DataSourceSheetView(item: item, focusNotification: focusNotification))
        }
    }

    @ViewBuilder
    private var rectangle: some View {
        if let item = itemList.bottomSheetItems?[selectedItem].item {
            Rectangle()
                .fill(Color(type(of: item).definition.color))
                .frame(maxWidth: 8, maxHeight: .infinity)
        }
    }
    
    var body: some View {
        Self._printChanges()
        return
            VStack {
                ZStack {
                    if let bottomSheetItems = itemList.bottomSheetItems, bottomSheetItems.count >= selectedItem + 1 {
                        let item = bottomSheetItems[selectedItem].item
                        HStack {
                            DataSourceCircleImage(dataSource: type(of: item), size: 30)
                            Spacer()
                        }
                        
                        if bottomSheetItems.count > 1 {
                            HStack(spacing: 8) {
                                Button(
                                    action: {
                                        withAnimation {
                                            selectedItem = max(0, selectedItem - 1)
                                        }
                                    },
                                    label: {
                                        Label(
                                            title: {},
                                            icon: { 
                                                Image(systemName: "chevron.left")
                                                .renderingMode(.template)
                                                .foregroundColor(selectedItem != 0
                                                                 ? Color.primaryColorVariant : Color.disabledColor
                                                )
                                        })
                                    }
                                )
                                .buttonStyle(MaterialButtonStyle())
                                .accessibilityElement()
                                .accessibilityLabel("previous")
                                
                                Text("\(selectedItem + 1) of \(pages)")
                                    .font(Font.caption)
                                    .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                                
                                Button(
                                    action: {
                                        withAnimation {
                                            selectedItem = min(pages - 1, selectedItem + 1)
                                        }
                                    },
                                    label: {
                                        Label(
                                            title: {},
                                            icon: { 
                                                Image(systemName: "chevron.right")
                                                .renderingMode(.template)
                                                .foregroundColor(pages - 1 != selectedItem
                                                                 ? Color.primaryColorVariant : Color.disabledColor)
                                            })
                                    }
                                )
                                .buttonStyle(MaterialButtonStyle())
                                .accessibilityElement()
                                .accessibilityLabel("next")
                            }
                        }
                    }
                }
                
                if (itemList.bottomSheetItems?.count ?? -1) >= selectedItem + 1,
                   let item = itemList.bottomSheetItems?[selectedItem] {
                    contentBuilder(item)
                        .transition(.opacity)
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
                // This can all be removed once all bottom sheet items focus properly
                if (itemList.bottomSheetItems?.count ?? -1) >= selectedItem + 1,
                   let bottomSheetItem = itemList.bottomSheetItems?[selectedItem],
                    let item = bottomSheetItem.item as? Locatable {
                    NotificationCenter.default.post(
                        name: focusNotification,
                        object: FocusMapOnItemNotification(
                            item: item,
                            zoom: bottomSheetItem.zoom,
                            mapName: bottomSheetItem.mapName,
                            definition: bottomSheetItem.item?.definition
                        )
                    )
                }
            }
            .onAppear {
                // This can all be removed once all bottom sheet items focus properly
                if (itemList.bottomSheetItems?.count ?? -1) >= selectedItem + 1,
                   let bottomSheetItem = itemList.bottomSheetItems?[selectedItem],
                   let item = bottomSheetItem.item as? Locatable {
                    NotificationCenter.default.post(
                        name: focusNotification,
                        object: FocusMapOnItemNotification(
                            item: item,
                            zoom: bottomSheetItem.zoom,
                            mapName: bottomSheetItem.mapName,
                            definition: bottomSheetItem.item?.definition
                        )
                    )
                    if let dataSource = item as? DataSource {
                        Metrics.shared.dataSourceBottomSheet(dataSource: type(of: dataSource).definition)
                    }
                }
            }
    }
}

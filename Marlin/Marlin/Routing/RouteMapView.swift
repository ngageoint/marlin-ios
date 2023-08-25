//
//  RouteMapView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/21/23.
//

import SwiftUI
import MapKit

struct RouteMapView: View {
    @State var showBottomSheet: Bool = false
    @StateObject var itemList: BottomSheetItemList = BottomSheetItemList()
    
    @Binding var path: NavigationPath
    @Binding var waypoints: [any DataSource]

    let focusMapAtLocation = NotificationCenter.default.publisher(for: .FocusMapAtLocation)

    @StateObject var mixins: MainMapMixins = MainMapMixins()
    @StateObject var mapState: MapState = MapState()
    
    let mapItemsTappedPub = NotificationCenter.default.publisher(for: NSNotification.Name("RouteMapTapped"))
    
    var body: some View {
        VStack {
            MarlinMap(notificationOnTap: NSNotification.Name("RouteMapTapped"), focusNotification: NSNotification.Name("RouteFocus"), name: "Marlin Map", mixins: mixins, mapState: mapState)
                .ignoresSafeArea()
        }
        .onReceive(focusMapAtLocation) { notification in
            mapState.forceCenter = notification.object as? MKCoordinateRegion
        }
        .overlay(bottomButtons(), alignment: .bottom)
        .overlay(topButtons(), alignment: .top)
        
        .onReceive(mapItemsTappedPub) { output in
            guard let notification = output.object as? MapItemsTappedNotification else {
                return
            }
            
            var bottomSheetItems: [BottomSheetItem] = []
            if let items = notification.items, !items.isEmpty {
                
                print("Route map items tapped")
                
                for item in items {
                    let bottomSheetItem = BottomSheetItem(item: item, mapName: "Route Map", zoom: false)
                    bottomSheetItems.append(bottomSheetItem)
                }
                itemList.bottomSheetItems = bottomSheetItems
                showBottomSheet.toggle()
            }

        }
        .sheet(isPresented: $showBottomSheet, onDismiss: {
            NSLog("dismissed")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "RouteFocus"), object: FocusMapOnItemNotification(item: nil))
        }) {
            MarlinBottomSheet(itemList: itemList, focusNotification: NSNotification.Name(rawValue: "RouteFocus")) { dataSourceViewBuilder in
                VStack {
                    Text(dataSourceViewBuilder.itemTitle)
                    HStack {
                        Button("Add To Route") {
                            print("add to route")
                            waypoints.append(dataSourceViewBuilder)
                        }
                        .buttonStyle(MaterialButtonStyle(type:.text))
                    }
                }
            }
            .environmentObject(LocationManager.shared())
            .presentationDetents([.height(150)])
        }
    }
    
    @ViewBuilder
    func topButtons() -> some View {
        HStack(alignment: .top, spacing: 8) {
            // top left button stack
            VStack(alignment: .leading, spacing: 8) {
                SearchView(mapState: mapState)
            }
            .padding(.leading, 8)
            .padding(.top, 16)
            Spacer()
        }
    }
    
    @ViewBuilder
    func bottomButtons() -> some View {
        HStack(alignment: .bottom, spacing: 0) {
            DataSourceToggles()
                .padding(.leading, 8)
                .padding(.bottom, 30)
            
            Spacer()
                .frame(maxWidth: .infinity)
            
            // bottom right button stack
            VStack(alignment: .trailing, spacing: 16) {
                UserTrackingButton(mapState: mapState)
                    .fixedSize()
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("User Tracking")
            }
            .padding(.trailing, 8)
            .padding(.bottom, 30)
        }
    }
}

//
//  RouteDataSourceSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import SwiftUI

struct RouteDataSourceSheetView: View {
    var item: BottomSheetItem
    @ObservedObject var routeViewModel: RouteViewModel
    @Binding var showBottomSheet: Bool

    var body: some View {
        Group {
            if let itemKey = item.itemKey, let dataSourceKey = item.dataSourceKey {
                switch dataSourceKey {
                case DataSources.asam.key:
                    AsamRouteSheetView(
                        itemKey: itemKey,
                        focusNotification: .RouteFocus,
                        routeViewModel: routeViewModel,
                        showBottomSheet: $showBottomSheet
                    )
                case DataSources.modu.key:
                    ModuRouteSheetView(
                        itemKey: itemKey,
                        focusNotification: .RouteFocus,
                        routeViewModel: routeViewModel,
                        showBottomSheet: $showBottomSheet
                    )
                case DataSources.port.key:
                    PortRouteSheetView(
                        itemKey: itemKey,
                        focusNotification: .RouteFocus,
                        routeViewModel: routeViewModel,
                        showBottomSheet: $showBottomSheet
                    )
                case DataSources.light.key:
                    LightRouteSheetView(
                        itemKey: itemKey,
                        focusNotification: .RouteFocus,
                        routeViewModel: routeViewModel,
                        showBottomSheet: $showBottomSheet
                    )
                case DataSources.radioBeacon.key:
                    RadioBeaconRouteSheetView(
                        itemKey: itemKey,
                        focusNotification: .RouteFocus,
                        routeViewModel: routeViewModel,
                        showBottomSheet: $showBottomSheet
                    )
                case DataSources.dgps.key:
                    DGPSStationRouteSheetView(
                        itemKey: itemKey,
                        focusNotification: .RouteFocus,
                        routeViewModel: routeViewModel,
                        showBottomSheet: $showBottomSheet
                    )
                case DataSources.navWarning.key:
                    NavigationalWarningRouteSheetView(
                        itemKey: itemKey,
                        focusNotification: .RouteFocus,
                        routeViewModel: routeViewModel,
                        showBottomSheet: $showBottomSheet
                    )
                default:
                    EmptyView()
                }
            }
        }
    }
}

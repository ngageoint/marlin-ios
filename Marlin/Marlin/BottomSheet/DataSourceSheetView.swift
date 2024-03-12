//
//  DataSourceSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import SwiftUI

struct DataSourceSheetView: View {
    var item: BottomSheetItem
    var focusNotification: NSNotification.Name

    var body: some View {
        Group {
            if let itemKey = item.itemKey, let dataSourceKey = item.dataSourceKey {
                switch dataSourceKey {
                case DataSources.asam.key:
                    AsamSheetView(itemKey: itemKey, focusNotification: focusNotification)
                case DataSources.modu.key:
                    ModuSheetView(itemKey: itemKey, focusNotification: focusNotification)
                case DataSources.port.key:
                    PortSheetView(itemKey: itemKey, focusNotification: focusNotification)
                case DataSources.light.key:
                    LightSheetView(
                        itemKey: itemKey,
                        focusNotification: focusNotification
                    )
                case DataSources.radioBeacon.key:
                    RadioBeaconSheetView(
                        itemKey: itemKey,
                        focusNotification: focusNotification
                    )
                case DataSources.dgps.key:
                    DGPSStationSheetView(
                        itemKey: itemKey,
                        focusNotification: focusNotification
                    )
                case DataSources.navWarning.key:
                    NavigationalWarningSheetView(
                        itemKey: itemKey,
                        focusNotification: focusNotification
                    )
                case DataSources.search.key:
                    SearchSheetView(
                        itemKey: itemKey,
                        focusNotification: focusNotification
                    )
                default:
                    EmptyView()
                }
            }
        }
    }
}

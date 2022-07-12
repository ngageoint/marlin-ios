//
//  DataSourceCell.swift
//  Marlin
//
//  Created by Daniel Barela on 7/5/22.
//

import SwiftUI

struct DataSourceCell<T>: View where T: DataSource {
    @EnvironmentObject var scheme: MarlinScheme
    
    @AppStorage<Bool> var showOnMap: Bool
    
    init() {
        self._showOnMap = AppStorage(wrappedValue: false, "showOnMap\(T.key)")
    }
    
    var body: some View {
        HStack {
            Text(T.dataSourceName)
            Spacer()
            if T.isMappable {
                Image(systemName: showOnMap ? "mappin.circle.fill" : "mappin.slash.circle.fill")
                    .renderingMode(.template)
                    .foregroundColor(Color(showOnMap ? scheme.containerScheme.colorScheme.primaryColor : scheme.disabledScheme.colorScheme.primaryColor))
                    .onTapGesture {
                        self.showOnMap = !self.showOnMap
                    }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            NotificationCenter.default.post(name: .SwitchTabs, object: T.key)
        }
    }
}

struct DataSourceCell_Previews: PreviewProvider {
    static var previews: some View {
        DataSourceCell<Asam>()
    }
}

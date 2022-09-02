//
//  SettingsCell.swift
//  Marlin
//
//  Created by Daniel Barela on 9/2/22.
//

import SwiftUI

struct SettingsCell: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Image(systemName: "gearshape.fill")
                    .tint(Color.onSurfaceColor)
                    .opacity(0.60)
                Text("Settings")
                    .font(Font.body1)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.87)
                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                NotificationCenter.default.post(name: .SwitchTabs, object: "settings")
            }
            .padding([.leading, .top, .bottom, .trailing], 16)
            Divider()
        }
        
        .background(Color.surfaceColor)
    }
}

struct SettingsCell_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCell()
    }
}

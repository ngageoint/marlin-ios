//
//  RailItem.swift
//  Marlin
//
//  Created by Daniel Barela on 7/29/22.
//

import SwiftUI

struct RailItem: View {    
    var imageName: String?
    var systemImageName: String?
    var itemText: String?
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            if let imageName = imageName {
                Image(imageName)
                    .frame(width: 24, height: 24, alignment: .center)
            } else if let systemImageName = systemImageName {
                Image(systemName: systemImageName)
            }
            if let itemText = itemText {
                Text(itemText)
                    .font(Font.caption)
            }
        }
        .frame(minWidth: 72, idealWidth: 72, maxWidth: 72, minHeight: 72, idealHeight: 72, maxHeight: 72)
    }
}

struct RailItem_Previews: PreviewProvider {
    static var previews: some View {
        RailItem()
    }
}

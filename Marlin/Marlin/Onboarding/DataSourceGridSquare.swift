//
//  DataSourceGridSquare.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/23.
//

import SwiftUI

struct DataSourceGridSquare: View {
    var dataSource: any DataSource.Type
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
    
    var gridSize: CGFloat {
        verticalSizeClass != .compact ? 100 : 75
    }
    
    var body: some View {
        VStack(alignment: .center) {
            if let image = dataSource.image {
                Image(uiImage: image)
                    .renderingMode(.template)
                    .frame(width: gridSize / 2, height: gridSize / 2)
                    .clipShape(Circle())
                    .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 2)
                        .background(Circle().fill(Color(uiColor: dataSource.definition.color))))
            }
            Text(dataSource.definition.name)
                .foregroundColor(Color.onPrimaryColor)
        }
        .frame(width: gridSize, height: gridSize)
        .background(Color.secondaryColor)
        .cornerRadius(2)
        .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
    }
}

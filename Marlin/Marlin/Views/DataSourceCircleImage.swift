//
//  DataSourceCircleImage.swift
//  Marlin
//
//  Created by Daniel Barela on 8/23/23.
//

import SwiftUI

struct DataSourceCircleImage: View {
    var dataSource: DataSource.Type
    var size: CGFloat = 30
    var body: some View {
        if let imageName = dataSource.definition.imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(.white)
                .padding(size / 3)
                .background(Color(dataSource.definition.color))
                .clipShape(Circle())
        } else if let systemImageName = dataSource.definition.systemImageName {
            Image(systemName: systemImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(.white)
                .padding(size / 3)
                .background(Color(dataSource.definition.color))
                .clipShape(Circle())
        }
    }
}

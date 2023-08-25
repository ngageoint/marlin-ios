//
//  DataSourceCircleImage.swift
//  Marlin
//
//  Created by Daniel Barela on 8/23/23.
//

import SwiftUI

struct DataSourceCircleImage: View {
    var dataSource: any DataSource
    var size: CGFloat = 30
    var body: some View {
        if let imageName = type(of: dataSource).imageName {
            Image(imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(.white)
                .padding(size / 3)
                .background(Color(dataSource.color))
                .clipShape(Circle())
        } else if let systemImageName = type(of: dataSource).systemImageName {
            Image(systemName: systemImageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
                .foregroundColor(.white)
                .padding(size / 3)
                .background(Color(dataSource.color))
                .clipShape(Circle())
        }
    }
}

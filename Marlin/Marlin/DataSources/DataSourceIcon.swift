//
//  DataSourceIcon.swift
//  Marlin
//
//  Created by Daniel Barela on 8/3/23.
//

import SwiftUI

struct DataSourceIcon: View {
    var dataSource: (any DataSource)?
    var body: some View {
        if let dataSource = dataSource {
            if let imageName = type(of: dataSource).imageName {
                Image(imageName)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color(dataSource.color))
                    .clipShape(Circle())
            } else if let systemImageName = type(of: dataSource).systemImageName {
                Image(systemName: systemImageName)
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color(dataSource.color))
                    .clipShape(Circle())
            }
        }
    }
}


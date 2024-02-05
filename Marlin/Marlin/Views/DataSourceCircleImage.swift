//
//  DataSourceCircleImage.swift
//  Marlin
//
//  Created by Daniel Barela on 8/23/23.
//

import SwiftUI

struct DataSourceCircleImage: View {
    var definition: (any DataSourceDefinition)?
    var size: CGFloat = 30
    var body: some View {
        if let definition = definition {
            if let imageName = definition.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .foregroundColor(.white)
                    .padding(size / 3)
                    .background(Color(definition.color))
                    .clipShape(Circle())
            } else if let systemImageName = definition.systemImageName {
                Image(systemName: systemImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .foregroundColor(.white)
                    .padding(size / 3)
                    .background(Color(definition.color))
                    .clipShape(Circle())
            }
        }
    }
}

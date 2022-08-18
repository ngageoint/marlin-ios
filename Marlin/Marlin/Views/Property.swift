//
//  Property.swift
//  Marlin
//
//  Created by Daniel Barela on 6/16/22.
//

import SwiftUI

struct KeyValue: Identifiable {
    var id = UUID()
    var key: String
    var value: String?
}

struct Property: View {
    
    var property: String
    var value: String?
    var body: some View {
        if let value = value, value != "" {
            VStack(alignment: .leading, spacing: 4) {
                Text(property).font(Font.body2).foregroundColor(Color.onSurfaceColor.opacity(0.60))
                Text(value).font(Font.subheadline).foregroundColor(Color.onSurfaceColor.opacity(0.87))
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct Property_Previews: PreviewProvider {
    static var previews: some View {
        Property(property: "Name", value: "Value")
    }
}

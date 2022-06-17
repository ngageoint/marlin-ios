//
//  Property.swift
//  Marlin
//
//  Created by Daniel Barela on 6/16/22.
//

import SwiftUI

struct Property: View {
    
    @EnvironmentObject var scheme: MarlinScheme

    var property: String
    var value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(property).font(Font(scheme.containerScheme.typographyScheme.body2)).foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor).opacity(0.60))
            Text(value).font(Font(scheme.containerScheme.typographyScheme.subtitle1)).foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor).opacity(0.87))
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct Property_Previews: PreviewProvider {
    static var previews: some View {
        Property(property: "Name", value: "Value")
    }
}

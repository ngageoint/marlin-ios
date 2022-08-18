//
//  KeyValueView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/18/22.
//

import SwiftUI

struct KeyValueSection: View {
    
    var sectionName: String
    var properties: [KeyValue]
    var isEmpty: Bool
    
    init(sectionName: String, properties: [KeyValue]) {
        self.sectionName = sectionName
        self.properties = properties
        var empty = true
        for property in properties {
            if property.value != nil && property.value != "" {
                empty = false
            }
        }
        isEmpty = empty
    }

    var body: some View {
        if !isEmpty {
            Section(sectionName) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(properties) { property in
                        Property(property: property.key, value: property.value)
                    }
                }
                .padding(.all, 16)
                .background(Color.surfaceColor)
                .modifier(CardModifier())
                .frame(maxWidth: .infinity)
            }
        }
    }
}

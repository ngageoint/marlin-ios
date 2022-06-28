//
//  Card.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import Foundation
import SwiftUI

struct CardModifier: ViewModifier {
    @EnvironmentObject var scheme: MarlinScheme
    
    func body(content: Content) -> some View {
        content
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
    }
    
}

struct UnreadModifier: ViewModifier {
    @EnvironmentObject var scheme: MarlinScheme
    
    func body(content: Content) -> some View {
        content            
            .padding(.top, 16)
            .padding(.bottom, 16)
            .padding(.leading, 24)
            .padding(.trailing, 24)
            .font(Font(scheme.containerScheme.typographyScheme.body2))
            .background(
                RoundedRectangle(cornerRadius: 16)
                .fill(Color(scheme.containerScheme.colorScheme.primaryColor))
                .padding(8)
                .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)

            )
            .foregroundColor(Color(scheme.containerScheme.colorScheme.onPrimaryColor))

    }
    
}

//
//  Card.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import Foundation
import SwiftUI

struct CardModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .cornerRadius(2)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
    }
    
}

struct UnreadModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content            
            .padding(.top, 16)
            .padding(.bottom, 16)
            .padding(.leading, 24)
            .padding(.trailing, 24)
            .font(Font.body2)
            .background(
                RoundedRectangle(cornerRadius: 16)
                .fill(Color.primaryColor)
                .padding(8)
                .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)

            )
            .foregroundColor(Color.onPrimaryColor)

    }
    
}

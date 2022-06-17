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

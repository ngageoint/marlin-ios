//
//  Badge.swift
//  Marlin
//
//  Created by Daniel Barela on 9/23/22.
//

import SwiftUI

struct Badge: View {
    let count: Int
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            if count != 0 {
                Image(systemName: "\(count).circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.secondaryColor)
                    .alignmentGuide(.top) { $0[.bottom] }
                    .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.25 }
            }
        }
    }
}

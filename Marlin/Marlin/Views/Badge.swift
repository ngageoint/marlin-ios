//
//  Badge.swift
//  Marlin
//
//  Created by Daniel Barela on 9/23/22.
//

import SwiftUI

struct Badge: View {
    let count: Int
    var positionShift: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            if count != 0 {
                Image(systemName: "\(count).circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.secondaryColor)
                    .alignmentGuide(.top) { $0[.bottom] - 5 - positionShift }
                    .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.25 }
            }
        }
    }
}

struct CheckBadge: View {
    @Binding var on: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.clear
            if on {
                Image(systemName: "checkmark.circle.fill")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, Color.secondaryColor)
                    .background(Circle().strokeBorder(Color.onPrimaryColor, lineWidth: 1))
                    .alignmentGuide(.top) { $0[.bottom] }
                    .alignmentGuide(.trailing) { $0[.trailing] - $0.width * 0.25 }
                    .accessibilityElement()
                    .accessibilityLabel("Check On")
            }
        }
    }
}

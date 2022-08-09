//
//  MaterialButtonStyle.swift
//  Marlin
//
//  Created by Daniel Barela on 7/1/22.
//

import Foundation
import SwiftUI

enum ButtonType {
    case text
    case outline
    case contained
}

struct MaterialButtonLabelStyle: LabelStyle {
    
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .foregroundColor(color)
                .font(Font.headline6)
            configuration.title
                .foregroundColor(color)
                .font(Font.title)
        }
    }
}

struct MaterialButtonStyle: ButtonStyle {
        
    let cornerRadius: CGFloat = 4.0
    let maxWidth: Bool = false
    let type: ButtonType
    
    func makeBody(configuration: Configuration) -> some View {
        var borderWidth = 1.0
        if type == .outline {
            borderWidth = 3.0
        } else if type == .text {
            borderWidth = 0.0
        }
        var foregroundColor = Color.primaryColor
        if type == ButtonType.contained {
            foregroundColor = Color.onPrimaryColor
        }
        
        return configuration
            .label
            .labelStyle(MaterialButtonLabelStyle(color: foregroundColor))
            .frame(minWidth: 44.0, maxWidth: maxWidth ? .infinity : nil, minHeight: 44.0)
            .padding([.trailing, .leading], 4)
            .font(Font.body2)
            .foregroundColor(foregroundColor)
            .background(
                GeometryReader { metrics in
                    let scale = max(metrics.size.width / metrics.size.height, metrics.size.height / metrics.size.width) * 1.1
                    ZStack {
                        if type == .contained {
                        // Solid fill
                            RoundedRectangle(cornerRadius: cornerRadius).fill(Color.primaryColor).shadow(color: Color(.sRGB, white: 0, opacity: 0.3), radius: (configuration.isPressed ? 8 : 2), x: 0, y: 2)
                            
                            // tap effect
                            Circle().fill(Color.white).scaleEffect(configuration.isPressed ? scale : 0.0001).opacity(configuration.isPressed ? 0.32 : 0.0).cornerRadius(cornerRadius)
                        } else if type == .text {
                            // tap effect
                            Circle().fill(Color.primaryColor).scaleEffect(configuration.isPressed ? scale : 0.0001).opacity(configuration.isPressed ? 0.16 : 0.0).cornerRadius(cornerRadius)
                        }
                    }
                }
            )
            .overlay(
                // border
                RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.primaryColor, lineWidth: borderWidth).opacity(0.2)
            )
    }
    
    init(type: ButtonType = .text) {
        self.type = type
    }
}

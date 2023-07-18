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

enum FloatingButtonType {
    case primary
    case secondary
    case custom
}

enum FloatingButtonSize {
    case mini
    case regular
}

struct MaterialButtonLabelStyle: LabelStyle {
    
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .foregroundColor(color)
                .font(.system(size: 18))
                .frame(width: 24, height: 24, alignment: .center)
            configuration.title
                .foregroundColor(color)
                .font(.system(size: 14))
        }
    }
}

struct MaterialFloatingButtonStyle: ButtonStyle {
    let regularSize: CGFloat = 56.0
    let miniSize: CGFloat = 40.0
    var finalSize: CGFloat { size == .mini ? miniSize : regularSize }
    var cornerRadius: CGFloat { finalSize / 2.0}
    let type: FloatingButtonType
    let size: FloatingButtonSize
    let extended: Bool
    let foregroundColor: Color
    let backgroundColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        let borderWidth = 0.0

        
        return configuration
            .label
            .labelStyle(MaterialButtonLabelStyle(color: foregroundColor))
            .frame(minWidth: finalSize, maxWidth: extended ? .infinity : finalSize, minHeight: finalSize, maxHeight: finalSize)
            .padding([.trailing, .leading], extended ? 16 : 0)
            .font(Font.body2)
            .foregroundColor(foregroundColor)
            .background(
                GeometryReader { metrics in
                    let scale = max(metrics.size.width / metrics.size.height, metrics.size.height / metrics.size.width) * 1.1
                    ZStack {
                        if type == .primary {
                            // Solid fill
                            RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor).shadow(color: Color(.sRGB, white: 0, opacity: 0.4), radius: (configuration.isPressed ? 8 : 3), x: 0, y: 4)
                            
                            // tap effect
                            Circle().fill(Color.white).scaleEffect(configuration.isPressed ? scale : 0.0001).opacity(configuration.isPressed ? 0.32 : 0.0).cornerRadius(cornerRadius)
                        } else if type == .secondary {
                            // Solid fill surface color
                            RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor).shadow(color: Color(.sRGB, white: 0, opacity: 0.4), radius: (configuration.isPressed ? 8 : 3), x: 0, y: 4)
                            
                            // tap effect
                            Circle().fill(Color.primaryColor).scaleEffect(configuration.isPressed ? scale : 0.0001).opacity(configuration.isPressed ? 0.16 : 0.0).cornerRadius(cornerRadius)
                        } else {
                            // Solid fill surface color
                            RoundedRectangle(cornerRadius: cornerRadius).fill(backgroundColor).shadow(color: Color(.sRGB, white: 0, opacity: 0.4), radius: (configuration.isPressed ? 8 : 3), x: 0, y: 4)
                            
                            // tap effect
                            Circle().fill(Color.surfaceColor).scaleEffect(configuration.isPressed ? scale : 0.0001).opacity(configuration.isPressed ? 0.16 : 0.0).cornerRadius(cornerRadius)
                        }
                    }
                }
            )
            .overlay(
                // border
                RoundedRectangle(cornerRadius: cornerRadius).stroke(Color.primaryColor, lineWidth: borderWidth).opacity(0.2)
            )
    }
    
    init(type: FloatingButtonType = .primary, size: FloatingButtonSize = .regular, extended: Bool = false, foregroundColor: Color? = nil, backgroundColor: Color? = nil) {
        self.type = type
        self.size = size
        self.extended = extended
        if let foregroundColor = foregroundColor {
            self.foregroundColor = foregroundColor
        } else if type == .primary {
            self.foregroundColor = Color.onPrimaryColor
        } else {
            self.foregroundColor = Color.primaryColorVariant
        }
        
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        } else if type == .primary {
            self.backgroundColor = Color.primaryColor
        } else {
            self.backgroundColor = Color.surfaceColor
        }
    }
}

struct MaterialButtonStyle: ButtonStyle {
        
    let cornerRadius: CGFloat = 4.0
    let maxWidth: Bool = false
    let type: ButtonType
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        var borderWidth = 1.0
        if type == .outline {
            borderWidth = 3.0
        } else if type == .text {
            borderWidth = 0.0
        }
        var foregroundColor = isEnabled ? Color.primaryColorVariant : Color.disabledColor
        if type == ButtonType.contained {
            foregroundColor = Color.onPrimaryColor
        }
        
        return configuration
            .label
            .labelStyle(MaterialButtonLabelStyle(color: foregroundColor))
            .frame(minWidth: 44.0, maxWidth: maxWidth ? .infinity : nil, minHeight: 44.0)
            .padding([.trailing, .leading], 8)
            .font(Font.body2)
            .foregroundColor(foregroundColor)
            .background(
                GeometryReader { metrics in
                    let scale = max(metrics.size.width / metrics.size.height, metrics.size.height / metrics.size.width) * 1.1
                    ZStack {
                        if type == .contained {
                        // Solid fill
                            RoundedRectangle(cornerRadius: cornerRadius).fill(isEnabled ? Color.primaryColor : Color.disabledBackground).shadow(color: Color(.sRGB, white: 0, opacity: 0.3), radius: (configuration.isPressed ? 8 : 2), x: 0, y: 2)
                            
                            // tap effect
                            Circle().fill(Color.white).scaleEffect(configuration.isPressed ? scale : 0.0001).opacity(configuration.isPressed ? 0.32 : 0.0).cornerRadius(cornerRadius)
                        } else if type == .text {
                            // tap effect
                            RoundedRectangle(cornerRadius: cornerRadius).fill(isEnabled ? Color.primaryColor : Color.disabledBackground).scaleEffect(configuration.isPressed ? scale : 0.0001).opacity(configuration.isPressed ? 0.16 : 0.0).cornerRadius(cornerRadius)
                        }
                    }
                }
            )
            .overlay(
                // border
                RoundedRectangle(cornerRadius: cornerRadius).stroke(isEnabled ? Color.primaryColor : Color.disabledColor, lineWidth: borderWidth).opacity(0.2)
            )
    }
    
    init(type: ButtonType = .text) {
        self.type = type
    }
}

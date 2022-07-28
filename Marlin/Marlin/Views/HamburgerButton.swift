//
//  HamburgerButton.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI

struct Hamburger: ViewModifier {
    @EnvironmentObject var scheme: MarlinScheme
    @Binding var menuOpen: Bool
    
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem (placement: .navigationBarLeading)  {
                Image(systemName: "line.3.horizontal")
                    .foregroundColor(Color(scheme.containerScheme.colorScheme.onPrimaryColor))
                    .onTapGesture {
                        menuOpen.toggle()
                    }
            }
        }
    }
}


struct HamburgerButton: View {
        
    @State private var isRotating = false
    @State private var isHidden = false
    let buttonTap: () -> Void

    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 3){
                
                Rectangle() // top
                    .frame(width: isRotating ? 23 : 25, height: geometry.size.height * 0.05)
                    .cornerRadius(geometry.size.height * 0.025)
                    .rotationEffect(.degrees(isRotating ? 48 : 0), anchor: .leading)
                    .transformEffect(CGAffineTransform(translationX: 0, y: isRotating ? -4 : 0))
                
                Rectangle() // middle
                    .frame(width: 23, height: geometry.size.height * 0.05)
                    .cornerRadius(geometry.size.height * 0.025)
                    .scaleEffect(isHidden ? 0 : 1, anchor: isHidden ? .trailing: .leading)
                    .opacity(isHidden ? 0 : 1)
                
                Rectangle() // bottom
                    .frame(width: isRotating ? 23 : 25, height: geometry.size.height * 0.05)
                    .cornerRadius(geometry.size.height * 0.025)
                    .rotationEffect(.degrees(isRotating ? -48 : 0), anchor: .leading)
                    .transformEffect(CGAffineTransform(translationX: 0, y: isRotating ? 4 : 0))
            }
            .onTapGesture {
                withAnimation(.interpolatingSpring(stiffness: 300, damping: 15)){
                    isRotating.toggle()
                    isHidden.toggle()
                    buttonTap()
                }
            }
        }
    }
}

struct HamburgerButton_Previews: PreviewProvider {
    static func tap() {
        print("button tap")
    }
    static var previews: some View {
        HamburgerButton(buttonTap: tap)
            .preferredColorScheme(.dark)
    }
}

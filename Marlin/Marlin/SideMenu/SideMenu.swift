//
//  SideMenu.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI

struct SideMenu: View {
    
    let width: CGFloat
    let isOpen: Bool
    let menuClose: () -> Void
    
    @EnvironmentObject var dataSourceList: DataSourceList
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GeometryReader { _ in
                    EmptyView()
                }
                .background(Color.gray.opacity(0.5))
                .opacity(self.isOpen ? 1.0 : 0.0)
                .animation(.default, value: self.isOpen)
                .onTapGesture {
                    withAnimation(.easeIn.delay(0.25)) {
                        self.menuClose()
                    }
                }
                .accessibilityElement()
                .accessibilityLabel("Backdrop \(self.isOpen ? "Open" : "Closed")")
                
                HStack {
                    HStack(spacing: 0) {
                    Rectangle()
                        .foregroundColor(Color.primaryColor)
                        .overlay(alignment: .bottomLeading) {
                            HStack {
                                Image("marlin_small")
                                    .renderingMode(.template)
                                    .foregroundColor(Color.onPrimaryColor)
                                    .tint(Color.onPrimaryColor)
                                Text("Marlin")
                                    .bold()
                                    .foregroundColor(Color.onPrimaryColor)
                                Spacer()
                            }
                            .offset(x: 16, y: 16)
                            .fixedSize(horizontal: true, vertical: false)
                            .rotationEffect(.degrees(-90), anchor: .topLeading)
                        }
                        .ignoresSafeArea()
                        .frame(width: geometry.safeAreaInsets.leading)
                        
                        SideMenuContent(model: SideMenuViewModel(dataSourceList: dataSourceList))
                            .frame(width: self.width)
                            
                    }
                    .background(Color.white // any non-transparent background
                        .shadow(color: Color(UIColor.label).opacity(0.3), radius: self.isOpen ? 8 : 0, x: 0, y: 0)
                    )
                    .offset(
                        x: self.isOpen
                        ? -geometry.safeAreaInsets.leading : -self.width - (2 * geometry.safeAreaInsets.leading),
                        y: 0
                    )
                    .animation(.default, value: self.isOpen)
                    
                    Spacer()
                }
            }
        }
    }
}

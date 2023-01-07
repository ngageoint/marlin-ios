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
    
    @ObservedObject var dataSourceList: DataSourceList
    
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
                
                HStack {
                    HStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(Color.primaryColorVariant)
                            .ignoresSafeArea()
                            .frame(width: geometry.safeAreaInsets.leading)
                        SideMenuContent(dataSourceList: dataSourceList)
                            .frame(width: self.width)
                            
                    }
                    .background(Color.white // any non-transparent background
                        .shadow(color: Color(UIColor.label).opacity(0.3), radius: self.isOpen ? 8 : 0, x: 0, y: 0)
                    )
                    .offset(x: self.isOpen ? -geometry.safeAreaInsets.leading : -self.width - (2 * geometry.safeAreaInsets.leading), y: 0)
                    .animation(.default, value: self.isOpen)
                    
                    Spacer()
                }
            }
        }
    }
}

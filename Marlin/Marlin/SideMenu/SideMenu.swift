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
                SideMenuContent(dataSourceList: dataSourceList)
                    .frame(width: self.width)
                    .background(Color.white // any non-transparent background
                        .shadow(color: Color(UIColor.label).opacity(0.3), radius: self.isOpen ? 8 : 0, x: 0, y: 0)
                    )
                    .offset(x: self.isOpen ? 0 : -self.width, y: 0)
                    .animation(.default, value: self.isOpen)
                    
                Spacer()
            }
        }
    }
}

//struct SideMenu_Previews: PreviewProvider {
//    static var previews: some View {
//        SideMenu()
//    }
//}

//
//  SideMenuTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/3/23.
//

import XCTest

import SwiftUI

@testable import Marlin

final class SideMenuTests: XCTestCase {
    
    override func setUp() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.registerMarlinDefaults()
    }
    
    func testSideMenuDataSources() {
        class PassThrough: ObservableObject {
            @Published var menuOpen: Bool = false
        }
        
        struct Container: View {
            @State var menuOpen: Bool = false
            @StateObject var dataSourceList: DataSourceList = DataSourceList()
            let appState = AppState()

            @ObservedObject var passThrough: PassThrough
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                GeometryReader { geometry in
                    SideMenu(width: geometry.size.width - 56,
                             isOpen: self.menuOpen,
                             menuClose: self.openMenu,
                             dataSourceList: dataSourceList
                    )
                    .environmentObject(appState)
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel("Side Menu")
                }
                .onChange(of: passThrough.menuOpen) { newValue in
                    menuOpen = newValue
                }
            }
            
            func openMenu() {
                self.menuOpen.toggle()
            }
        }
        let pt = PassThrough()
        
        let rail = Container(passThrough: pt)
        let controller = UIHostingController(rootView: rail)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "Side Menu")
        
        pt.menuOpen = true
        tester().waitForView(withAccessibilityLabel: "Backdrop Open")
        tester().tapScreen(at: CGPoint(x: UIScreen.main.bounds.size.width - 20, y: 60))
        tester().tapView(withAccessibilityLabel: "Backdrop Closed")
    }
}

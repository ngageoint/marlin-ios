//
//  HamburgerButtonTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/13/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class HamburgerTests: XCTestCase {
    
    func testHamburger() {
        UserDefaults.standard.setFilter(MockDataSource.key, filter: [])
        
        class PassThrough {
            var menuOpen: Bool = false
        }
        
        struct Container: View {
            @State var menuOpen = false
            let passThrough: PassThrough
            
            var body: some View {
                Rectangle()
                    .background(Color.ngaGreen)
                    .modifier(Hamburger(menuOpen: $menuOpen))
                    .onChange(of: menuOpen) { newValue in
                        self.passThrough.menuOpen = newValue
                    }
            }
            
            public init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let nav = NavigationView {
            view
        }
        
        let controller = UIHostingController(rootView: nav)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        
        tester().waitForView(withAccessibilityLabel: "Side Menu")
        tester().tapView(withAccessibilityLabel: "Side Menu")
        
        XCTAssertTrue(passThrough.menuOpen)
    }

}

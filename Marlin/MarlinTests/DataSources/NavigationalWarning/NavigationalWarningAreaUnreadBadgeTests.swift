//
//  NavigationalWarningAreaUnreadBadgeTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class NavigationalWarningAreaUnreadBadgeTests: XCTestCase {

    func testNoneRead() throws {
        var warnings: [NavigationalWarningModel] = []
        var navWarning2 = NavigationalWarningModel(navArea: "A")
            navWarning2.msgYear = 2022
            navWarning2.msgNumber = 1178
            navWarning2.navArea = "A"
            navWarning2.subregion = "11,26"
            navWarning2.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning2.status = "A"
            navWarning2.issueDate = Date()
            navWarning2.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            warnings.append(navWarning2)
            
        var navWarning3 = NavigationalWarningModel(navArea: "A")
            navWarning3.msgYear = 2022
            navWarning3.msgNumber = 1179
            navWarning3.navArea = "A"
            navWarning3.subregion = "11,26"
            navWarning3.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning3.status = "A"
            navWarning3.issueDate = Date()
            navWarning3.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            warnings.append(navWarning3)

        
        let view = NavigationalWarningAreaUnreadBadge(unreadCount: 2)

        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "2 Unread")
    }
    
    func testOneRead() throws {
        var warnings: [NavigationalWarningModel] = []

            var navWarning2 = NavigationalWarningModel(navArea: "A")
            navWarning2.msgYear = 2022
            navWarning2.msgNumber = 1178
            navWarning2.navArea = "A"
            navWarning2.subregion = "11,26"
            navWarning2.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning2.status = "A"
            navWarning2.issueDate = Date()
            navWarning2.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            warnings.append(navWarning2)
            
            var navWarning3 = NavigationalWarningModel(navArea: "A")
            navWarning3.msgYear = 2022
            navWarning3.msgNumber = 1179
            navWarning3.navArea = "A"
            navWarning3.subregion = "11,26"
            navWarning3.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning3.status = "A"
            navWarning3.issueDate = Date()
            navWarning3.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            warnings.append(navWarning3)
            

        class PassThrough: ObservableObject {
            var navArea: String
            var warnings: [NavigationalWarningModel]

            init(navArea: String, warnings: [NavigationalWarningModel]) {
                self.navArea = navArea
                self.warnings = warnings
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    NavigationalWarningAreaUnreadBadge(unreadCount: 1)
                }
            }
        }
        
        UserDefaults.standard.setValue(warnings[1].primaryKey, forKey: "lastSeen-A")
        
        let appState = AppState()
        let passThrough = PassThrough(navArea: "A", warnings: warnings)
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForView(withAccessibilityLabel: "1 Unread")
    }
    
    // this should be tested in a different view
    func xtestAllRead() throws {
        print("all read")
        var warnings: [NavigationalWarningModel] = []

            var navWarning2 = NavigationalWarningModel(navArea: "A")
            navWarning2.msgYear = 2022
            navWarning2.msgNumber = 1178
            navWarning2.navArea = "A"
            navWarning2.subregion = "11,26"
            navWarning2.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning2.status = "A"
            navWarning2.issueDate = Date()
            navWarning2.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            warnings.append(navWarning2)
            
            var navWarning3 = NavigationalWarningModel(navArea: "A")
            navWarning3.msgYear = 2022
            navWarning3.msgNumber = 1179
            navWarning3.navArea = "A"
            navWarning3.subregion = "11,26"
            navWarning3.text = "WESTERN NORTH ATLANTIC.\nFLORIDA.\n1. HAZARDOUS OPERATIONS, ROCKET LAUNCHING\n   121606Z TO 121854Z NOV, ALTERNATE\n   131606Z TO 131854Z AND 1607Z TO 1854Z DAILY\n   14 THRU 18 NOV IN AREAS BOUND BY:\n   A. 28-39.92N 080-38.33W, 28-40.00N 079-44.00W,\n      28-28.00N 079-40.00W, 28-29.97N 080-32.29W\n   B. 27-51.00N 073-56.00W, 28-37.00N 073-55.00W,\n      28-40.00N 071-21.00W, 28-13.00N 069-58.00W,\n      27-31.00N 069-58.00W, 27-21.00N 071-43.00W.\n2. CANCEL NAVAREA IV 1165/22.\n3. CANCEL THIS MSG 181954Z NOV 22.\n"
            navWarning3.status = "A"
            navWarning3.issueDate = Date()
            navWarning3.authority = "EASTERN RANGE 0/22 072203Z NOV 22."
            
            warnings.append(navWarning3)
        
        class PassThrough: ObservableObject {
            var navArea: String
            var warnings: [NavigationalWarningModel]

            init(navArea: String, warnings: [NavigationalWarningModel]) {
                self.navArea = navArea
                self.warnings = warnings
            }
        }
        
        struct Container: View {
            
            @ObservedObject var passThrough: PassThrough
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
            }
            
            var body: some View {
                NavigationView {
                    NavigationalWarningAreaUnreadBadge(unreadCount: 2)
                }
            }
        }
        
        UserDefaults.standard.setValue(warnings[0].primaryKey, forKey: "lastSeen-A")
        
        let appState = AppState()
        let passThrough = PassThrough(navArea: "A", warnings: warnings)
        
        let container = Container(passThrough: passThrough)
            .environmentObject(appState)
        
        let controller = UIHostingController(rootView: container)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForAnimationsToFinish()
        tester().waitForAbsenceOfView(withAccessibilityLabel: "2 Unread")
    }

}

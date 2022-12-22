//
//  TestHelper.swift
//  MarlinTests
//
//  Created by Daniel Barela on 6/6/22.
//

import Foundation
import UIKit

@testable import Marlin

class TestHelpers {
    
    public static func getKeyWindowVisible() -> UIWindow {
        var window: UIWindow;
        if (UIApplication.shared.windows.count == 0) {
            window = UIWindow(frame: UIScreen.main.bounds)
        } else {
            NSLog("There are \(UIApplication.shared.windows.count) windows");
            if (UIApplication.shared.windows.count != 1) {
                NSLog("Windows are \(UIApplication.shared.windows)")
            }
            window = UIApplication.shared.windows[0];
        }
        window.backgroundColor = .systemBackground;
        window.makeKeyAndVisible();
        return window;
    }
    
    public static func getAllAccessibilityLabels(_ viewRoot: UIView) -> [String]! {
        var array = [String]()
        for view in viewRoot.subviews {
            if let lbl = view.accessibilityLabel {
                array += [lbl]
            }
            
            array += getAllAccessibilityLabels(view)
        }
        
        return array
    }
    
    public static func getAllAccessibilityLabelsInWindows() -> [String]! {
        var labelArray = [String]()
        for  window in UIApplication.shared.windowsWithKeyWindow() {
            print("window \(window)")
            labelArray += getAllAccessibilityLabels(window as! UIWindow )
        }
        
        return labelArray
    }
    
    public static func printAllAccessibilityLabelsInWindows() {
        let labelArray = TestHelpers.getAllAccessibilityLabelsInWindows();
        NSLog("labelArray = \(labelArray ?? [])")
    }
    
    static func clearData() {
//        let asamsTruncated = PersistenceController.shared.container.viewContext.truncateAll(Asam.self)
//        print("Asams truncated? \(asamsTruncated)")
//        let modusTruncated = PersistenceController.shared.container.viewContext.truncateAll(Modu.self)
//        print("Modus truncated? \(modusTruncated)")
//        let navigationalWarningsTruncated = PersistenceController.shared.container.viewContext.truncateAll(NavigationalWarning.self)
//        print("Navigational Warnings truncated? \(navigationalWarningsTruncated)")
//        let lightsTruncated = PersistenceController.shared.container.viewContext.truncateAll(Light.self)
//        print("Lights truncated? \(lightsTruncated)")
    }
}

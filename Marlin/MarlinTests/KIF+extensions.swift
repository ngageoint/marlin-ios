//
//  KIF+Extensions.swift
//
//  Created by Daniel Barela on 6/10/20.
//

import KIF
extension XCTestCase {
    func tester(file : String = #file, _ line : Int = #line) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }
    
    func system(file : String = #file, _ line : Int = #line) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
    
    func viewTester(file: String = #file, _ line: Int = #line) -> KIFUIViewTestActor {
        return KIFUIViewTestActor(inFile: file, atLine: line, delegate: self)
    }
}

extension KIFTestActor {
    func tester(file : String = #file, _ line : Int = #line) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }
    
    func system(file : String = #file, _ line : Int = #line) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
    
    func viewTester(file: String = #file, _ line: Int = #line) -> KIFUIViewTestActor {
        return KIFUIViewTestActor(inFile: file, atLine: line, delegate: self)
    }
}

extension KIFUITestActor {
    func tapMiddlePointInView(accessibilityLabel: String) {
        self.waitForTappableView(withAccessibilityLabel: accessibilityLabel)
        if let view = viewTester().usingLabel(accessibilityLabel).view {

            //        view?.tap()
            let point = view.convert(CGPoint(x: 20.0, y: view.bounds.size.height / 2.0), to: nil)
            tapScreen(at: point)
        }

    }
}

extension UIView {

    func isProbablyTappable() -> Bool {
        return false
    }

//    - (BOOL)isProbablyTappable
//    {
//        // There are some issues with the tappability check in WKWebViews, so if the view is a WKWebView we will just skip the check.
//        return [NSStringFromClass([self class]) isEqualToString:@"UIWebBrowserView"] || self.isTappable;
//    }


//    - (void)tapMiddlePoinInViewWithAccessibilityLabel:(NSString *)label {
//        UIView *view = [tester waitForViewWithAccessibilityLabel:label];
//        CGPoint middlePointOnScreen = [view convertPoint:CGPointMake(view.bounds.size.width / 2.0, view.bounds.size.height / 2.0) toView:nil];
//        [tester tapScreenAtPoint:middlePointOnScreen];
//
//    }
}

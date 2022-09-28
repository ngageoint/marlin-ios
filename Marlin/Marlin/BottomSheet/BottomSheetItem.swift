//
//  BottomSheetItem.swift
//  Marlin
//
//  Created by Daniel Barela on 8/9/22.
//

import Foundation
import MapKit

class BottomSheetItem: NSObject, Identifiable {
    var item: any DataSource
    var annotationView: MKAnnotationView?
    var actionDelegate: Any?
    
    init(item: any DataSource, actionDelegate: Any? = nil, annotationView: MKAnnotationView? = nil) {
        self.item = item;
        self.actionDelegate = actionDelegate;
        self.annotationView = annotationView;
    }
}

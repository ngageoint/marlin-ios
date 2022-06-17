//
//  MarlinMap.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import UIKit
import SwiftUI

struct MarlinMap: UIViewRepresentable {
    
    @EnvironmentObject var scheme: MarlinScheme
    
    func makeUIView(context: Context) -> MarlinMapView {
        let control = MarlinMapView(scheme: scheme)
        return control
    }
    
    func updateUIView(_ uiView: MarlinMapView, context: Context) {
    }
}

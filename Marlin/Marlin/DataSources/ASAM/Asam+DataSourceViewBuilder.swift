//
//  Asam+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension Asam: DataSourceViewBuilder {    
    var itemTitle: String {
        return "\(self.hostility ?? "")\(self.hostility != nil && self.victim != nil ? ": " : "")\(self.victim ?? "")"
    }
    var detailView: AnyView {
        AnyView(AsamDetailView(reference: self.reference!))
//        AnyView(AsamDetailView(asam: self))
    }
    
    var summary: some DataSourceSummaryView {
        AsamSummaryView(asam: AsamModel(asam: self))
    }
}

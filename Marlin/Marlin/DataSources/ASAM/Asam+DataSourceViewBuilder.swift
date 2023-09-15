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
        if let reference = self.reference {
            return AnyView(AsamDetailView(reference: reference))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var summary: some DataSourceSummaryView {
        AsamSummaryView(asam: AsamModel(asam: self))
    }
}

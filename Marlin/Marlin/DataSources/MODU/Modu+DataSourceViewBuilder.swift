//
//  Modu+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension Modu: DataSourceViewBuilder {
//    typealias Summary = ModuSummaryView
    var itemTitle: String {
        return "\(self.name ?? "")"
    }
    
    var detailView: AnyView {
        AnyView(ModuDetailView(modu: self))
    }
    
//    func summaryView() -> Summary {
//        ModuSummaryView(modu: self)
//    }
    
    var summary: some DataSourceSummaryView {
        ModuSummaryView(modu: self)
    }
}

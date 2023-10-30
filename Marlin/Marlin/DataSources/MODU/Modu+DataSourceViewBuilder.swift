//
//  Modu+DataSourceViewBuilder.swift
//  Marlin
//
//  Created by Daniel Barela on 9/17/22.
//

import Foundation
import SwiftUI

extension Modu: DataSourceViewBuilder {
    var itemTitle: String {
        return "\(self.name ?? "")"
    }
    
    var detailView: AnyView {
        if let name = self.name {
            return AnyView(ModuDetailView(name: name))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var summary: some DataSourceSummaryView {
        ModuSummaryView(modu: ModuModel(modu: self))
    }
}

extension ModuModel: DataSourceViewBuilder {
    var detailView: AnyView {
        if let name = self.name {
            return AnyView(ModuDetailView(name: name))
        } else {
            return AnyView(EmptyView())
        }
    }
    
    var summary: some DataSourceSummaryView {
        ModuSummaryView(modu: self)
    }
}

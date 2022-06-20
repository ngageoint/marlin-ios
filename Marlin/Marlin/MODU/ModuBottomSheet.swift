//
//  ModuBottomSheet.swift
//  Marlin
//
//  Created by Daniel Barela on 6/17/22.
//

import Foundation
import SwiftUI

class ModuBottomSheetViewController: UIHostingController<ModuBottomSheet> {
    let modu: Modu
    let scheme: MarlinScheme
    
    init(modu: Modu, scheme: MarlinScheme) {
        self.modu = modu
        self.scheme = scheme
        let moduBottomSheet = ModuBottomSheet(modu: modu, scheme: scheme)
        super.init(rootView: moduBottomSheet)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct ModuBottomSheet: View {
    
    var modu: Modu
    var scheme: MarlinScheme?
    
    var body: some View {
        Group {
            if let scheme = scheme {
                ModuSummaryView(modu: modu, showMoreDetails: true).environmentObject(scheme)
            } else {
                ModuSummaryView(modu: modu, showMoreDetails: true)
            }
        }.padding(.all, 16)
    }
}

struct ModuBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let modu = try? context.fetchFirst(Modu.self)
        return ModuBottomSheet(modu: modu!)
    }
}

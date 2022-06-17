//
//  AsamBottomSheet.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import SwiftUI

class AsamBottomSheetViewController: UIHostingController<AsamBottomSheet> {
    let asam: Asam
    let scheme: MarlinScheme
    
    init(asam: Asam, scheme: MarlinScheme) {
        self.asam = asam
        self.scheme = scheme
        let asamBottomSheet = AsamBottomSheet(asam: asam, scheme: scheme)
        super.init(rootView: asamBottomSheet)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct AsamBottomSheet: View {
        
    var asam: Asam
    var scheme: MarlinScheme?
    
    var body: some View {
        Group {
            if let scheme = scheme {
                AsamSummaryView(asam: asam, showMoreDetails: true).environmentObject(scheme)
            } else {
                AsamSummaryView(asam: asam, showMoreDetails: true)
            }
        }.padding(.all, 16)
    }
}

struct AsamBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let asam = try? context.fetchFirst(Asam.self)
        return AsamBottomSheet(asam: asam!)
    }
}

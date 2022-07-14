//
//  LightBottomSheet.swift
//  Marlin
//
//  Created by Daniel Barela on 7/14/22.
//

import SwiftUI

class LightBottomSheetViewController: UIHostingController<LightBottomSheet> {
    let light: Lights
    let scheme: MarlinScheme
    
    init(light: Lights, scheme: MarlinScheme) {
        self.light = light
        self.scheme = scheme
        let lightBottomSheet = LightBottomSheet(light: light, scheme: scheme)
        super.init(rootView: lightBottomSheet)
    }
    
    @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct LightBottomSheet: View {
    var light: Lights
    var scheme: MarlinScheme?
    
    var body: some View {
        Group {
            if let scheme = scheme {
                LightSummaryView(light: light, showMoreDetails: true).environmentObject(scheme)
            } else {
                LightSummaryView(light: light, showMoreDetails: true)
            }
        }.padding(.all, 16)
    }
}

struct LightBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let light = try? context.fetchFirst(Lights.self)
        LightBottomSheet(light: light!)
    }
}

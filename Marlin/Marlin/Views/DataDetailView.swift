//
//  DataDetailView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/6/22.
//

import SwiftUI

struct DataDetailView: View {
    var data: DataSource?
    
    var body: some View {
        if let asam = data as? Asam {
            AsamDetailView(asam: asam)
        } else if let modu = data as? Modu {
            ModuDetailView(modu: modu)
        } else if let navigationalWarning = data as? NavigationalWarning {
            NavigationalWarningDetailView(navigationalWarning: navigationalWarning)
        } else if let light = data as? Light {
            if let featureNumber = light.featureNumber, let volumeNumber = light.volumeNumber {
                LightDetailView(featureNumber: featureNumber, volumeNumber: volumeNumber)
            }
        }
    }
}

//struct DataDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DataDetailView()
//    }
//}

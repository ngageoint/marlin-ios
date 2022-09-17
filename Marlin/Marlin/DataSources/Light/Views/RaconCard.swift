//
//  RaconCard.swift
//  Marlin
//
//  Created by Daniel Barela on 7/11/22.
//

import SwiftUI

struct RaconCard: View {    
    @State var racon: Light
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(racon.name ?? "")
                .primary()
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    if let morseCode = racon.morseCode {
                        Text("Signal")
                            .primary()
                        MorseCode(code: morseCode)
                        Text(racon.characteristic ?? "")
                            .secondary()
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Remarks")
                        .primary()
                    Text(racon.remarks ?? "")
                        .secondary()
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity)
        }
        .padding(.all, 16)
        .card()
        .frame(maxWidth: .infinity)
    }
}

//struct RaconCard_Previews: PreviewProvider {
//    static var previews: some View {
//        RaconCard()
//    }
//}

//
//  RaconCard.swift
//  Marlin
//
//  Created by Daniel Barela on 7/11/22.
//

import SwiftUI

struct RaconCard: View {
    @EnvironmentObject var scheme: MarlinScheme
    
    @State var racon: Lights
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(racon.name ?? "")
                .font(Font(scheme.containerScheme.typographyScheme.headline6))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.87)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    if let morseCode = racon.morseCode {
                        Text("Signal")
                            .font(Font(scheme.containerScheme.typographyScheme.body1))
                            .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                            .opacity(0.87)
                        MorseCode(code: morseCode)
//                        Text(morseCode)
//                            .font(Font(scheme.containerScheme.typographyScheme.headline2))
//                            .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
//                            .opacity(0.87)
                        Text(racon.characteristic ?? "")
                            .font(Font(scheme.containerScheme.typographyScheme.body2))
                            .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                            .opacity(0.6)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Remarks")
                        .font(Font(scheme.containerScheme.typographyScheme.body1))
                        .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                        .opacity(0.87)
                    Text(racon.remarks ?? "")
                        .font(Font(scheme.containerScheme.typographyScheme.body2))
                        .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                        .opacity(0.6)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity)
        }
        .padding(.all, 16)
        .background(Color(scheme.containerScheme.colorScheme.surfaceColor))
        .modifier(CardModifier())
        .frame(maxWidth: .infinity)
    }
}

//struct RaconCard_Previews: PreviewProvider {
//    static var previews: some View {
//        RaconCard()
//    }
//}

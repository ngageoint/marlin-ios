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
                .font(Font.headline6)
                .foregroundColor(Color.onSurfaceColor)
                .opacity(0.87)
                .fixedSize(horizontal: false, vertical: true)
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    if let morseCode = racon.morseCode {
                        Text("Signal")
                            .font(Font.headline6)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.87)
                        MorseCode(code: morseCode)
                        Text(racon.characteristic ?? "")
                            .font(Font.body2)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.6)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Remarks")
                        .font(Font.headline6)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.87)
                    Text(racon.remarks ?? "")
                        .font(Font.body2)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.6)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            }.frame(maxWidth: .infinity)
        }
        .padding(.all, 16)
        .background(Color.surfaceColor)
        .modifier(CardModifier())
        .frame(maxWidth: .infinity)
    }
}

//struct RaconCard_Previews: PreviewProvider {
//    static var previews: some View {
//        RaconCard()
//    }
//}

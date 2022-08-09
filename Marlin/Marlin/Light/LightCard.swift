//
//  LightCard.swift
//  Marlin
//
//  Created by Daniel Barela on 7/11/22.
//

import SwiftUI

struct LightCard: View {
    var light: Light
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(light.name ?? "")
                        .font(Font.headline6)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.87)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(light.expandedCharacteristic ?? "")
                        .font(Font.body2)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.6)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                
                if let lightSectors = light.lightSectors, let uiImage = LightColorImage(
                    frame: CGRect(x: 0, y: 0, width: 25, height: 25),
                    sectors: lightSectors), let darkuiImage = LightColorImage(
                        frame: CGRect(x: 0, y: 0, width: 25, height: 25),
                        sectors: lightSectors, darkMode: true) {
                    AdaptiveImage(lightImage: Image(uiImage: uiImage), darkImage: Image(uiImage: darkuiImage))
                        .aspectRatio(contentMode: .fit)
                }
            }
            
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Range (nm)")
                        .font(Font.title)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.87)
                    Text(light.range ?? "")
                        .font(Font.body2)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.6)
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Remarks")
                        .font(Font.title)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.87)
                    Text(light.remarks ?? "")
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

//struct LightCard_Previews: PreviewProvider {
//    static var previews: some View {
//        LightCard()
//    }
//}

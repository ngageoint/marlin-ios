//
//  LightCard.swift
//  Marlin
//
//  Created by Daniel Barela on 7/11/22.
//

import SwiftUI

struct LightCard: View {
    var light: LightModel
    var image: Image?
    
    init(light: LightModel) {
        self.light = light
        if let lightSectors = light.lightSectors, let uiImage = CircleImage(
            suggestedFrame: CGRect(x: 0, y: 0, width: 25, height: 25),
            sectors: lightSectors, outerStroke: UIColor.lightGray, fill: true, sectorSeparator: false) {
            image = Image(uiImage: uiImage)
        } else if let lightColors = light.lightColors {
            var sectors: [ImageSector] = []
            var count = 0
            let degreesPerColor = 360.0 / CGFloat(lightColors.count)
            for color in lightColors {
                sectors.append(
                    ImageSector(
                        startDegrees: degreesPerColor * CGFloat(count),
                        endDegrees: degreesPerColor * (CGFloat(count) + 1.0),
                        color: color
                    )
                )
                count += 1
            }
            let uiImage = CircleImage(
                suggestedFrame: CGRect(x: 0, y: 0, width: 25, height: 25),
                sectors: sectors,
                outerStroke: UIColor.lightGray,
                fill: true,
                sectorSeparator: false
            )
            if let uiImage = uiImage {
                image = Image(uiImage: uiImage)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(light.name ?? "")
                        .primary()
                        .fixedSize(horizontal: false, vertical: true)
                    Text(light.expandedCharacteristic ?? "")
                        .secondary()
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
                
                if let image = image {
                    image.aspectRatio(contentMode: .fit)
                        .accessibilityElement()
                        .accessibilityLabel("Light image")
                }
            }
            
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Range (nm)")
                        .primary()
                    Text(light.range ?? "")
                        .secondary()
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Remarks")
                        .primary()
                    Text(light.remarks ?? "")
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

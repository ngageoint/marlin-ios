//
//  MorseCode.swift
//  Marlin
//
//  Created by Daniel Barela on 7/11/22.
//

import SwiftUI

struct MorseCode: View {    
    var code: String
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if let split = code.split(separator: " ") {
                ForEach(split, id: \.self) { letter in
                    if letter == "-" || letter == "•" {
                        Rectangle()
                            .frame(width: letter == "-" ? 24 : 8, height: 5, alignment: .center)
                            .background(Color.onSurfaceColor)
                    }
                }
            }
        }
    }
}

struct MorseCode_Previews: PreviewProvider {
    static var previews: some View {
        MorseCode(code: "- • - ")
    }
}

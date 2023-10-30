//
//  MorseCode.swift
//  Marlin
//
//  Created by Daniel Barela on 7/11/22.
//

import SwiftUI

struct MorseCode: View {    
    var code: String
    
    init(code: String) {
        self.code = code.replacingOccurrences(of: "\t", with: "   ", options: .regularExpression)
        self.code = self.code.replacingOccurrences(of: "\\s", with: " ", options: .regularExpression)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(code.enumerated()), id: \.offset) { index, letter in
                if letter == "-" {
                    Rectangle()
                        .frame(width: 24, height: 5, alignment: .center)
                        .foregroundColor(Color.onSurfaceColor)
                } else if letter == "•" {
                    Rectangle()
                        .frame(width: 8, height: 5, alignment: .center)
                        .foregroundColor(Color.onSurfaceColor)
                } else {
                    Rectangle()
                        .frame(width: 8, height: 5, alignment: .center)
                        .foregroundColor(Color.clear)
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

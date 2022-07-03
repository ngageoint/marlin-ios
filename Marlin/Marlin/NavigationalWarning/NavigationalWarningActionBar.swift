//
//  NavigationalWarningActionBar.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI

struct NavigationalWarningActionBar: View {
    var navigationalWarning: NavigationalWarning
    
    var body: some View {
        HStack(spacing:0) {
            Spacer()
            Button(action: {
                let activityVC = UIActivityViewController(activityItems: [navigationalWarning.description], applicationActivities: nil)
                UIApplication.shared.keyWindow?.rootViewController?.present(activityVC, animated: true, completion: nil)
            }) {
                Label(
                    title: {},
                    icon: { Image(systemName: "square.and.arrow.up")
                            .renderingMode(.template)
                    })
            }
        }
        .buttonStyle(MaterialButtonStyle())
    }
}

//struct NavigationalWarningActionBar_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationalWarningActionBar()
//    }
//}

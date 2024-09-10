//
//  CreateUserPlaceButton.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import SwiftUI

struct CreateUserPlaceButton: View {
    @EnvironmentObject var router: MarlinRouter

    var body: some View {
        Button {
            router.path.append(UserPlaceRoute.create)
        } label: {
            Label(
                title: { },
                icon: { Image(systemName: "mappin.and.ellipse")
                        .renderingMode(.template)
                }
            )
        }
        .fixedSize()
        .buttonStyle(
            MaterialFloatingButtonStyle(
                type: .secondary,
                size: .mini,
                foregroundColor: Color.primaryColorVariant,
                backgroundColor: Color.mapButtonColor
            )
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("User Places Button")
    }
}

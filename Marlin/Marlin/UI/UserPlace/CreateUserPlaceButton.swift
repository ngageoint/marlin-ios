//
//  CreateUserPlaceButton.swift
//  Marlin
//
//  Created by Daniel Barela on 3/1/24.
//

import Foundation
import SwiftUI

struct CreateUserPlaceButton: View {

    var body: some View {
        NavigationLink(value: UserPlaceRoute.create) {
            Label(
                title: {},
                icon: { Image(systemName: "mappin.and.ellipse")
                        .renderingMode(.template)
                }
            )
        }
        .isDetailLink(false)
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

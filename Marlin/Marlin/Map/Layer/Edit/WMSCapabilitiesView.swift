//
//  WMSCapabilitiesView.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation
import SwiftUI

struct WMSCapabilitiesView: View {
    @ObservedObject var viewModel: MapLayerViewModel

    var body: some View {
        if let capabilities = viewModel.capabilities {
            Group {
                Text("WMS Server Information")
                    .overline()
                DisclosureGroup {
                    VStack(alignment: .leading, spacing: 8) {
                        Property(property: "Layer Count", value: "\(capabilities.totalLayers)")
                        Property(property: "WMS Version", value: capabilities.version)
                        Property(property: "Contact Person", value: capabilities.contactPerson)
                        Property(property: "Contact Organization", value: capabilities.contactOrganization)
                        if let phone = capabilities.contactTelephone {
                            Property(property: "Contact Telephone", valueView: AnyView(
                                Link(phone, destination: URL(string: "tel:\(phone)")!)
                                    .font(Font.subheadline)
                                    .foregroundColor(Color.primaryColor)
                            ))
                        }
                        if let email = capabilities.contactEmail {
                            Property(property: "Contact Email", valueView: AnyView(
                                Link(email, destination: URL(string: "mailto:\(email)")!)
                                    .font(Font.subheadline)
                                    .foregroundColor(Color.primaryColor)
                            ))
                        }
                    }

                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(capabilities.title ?? "WMS Server Information")
                            .primary()
                        Text(capabilities.abstract ?? "")
                            .secondary()
                    }
                }
                .tint(Color.primaryColor)
                .frame(maxWidth: .infinity)
                .accessibilityElement(children: .contain)
                .accessibilityLabel("More Server Information")
            }
            .background(Color.surfaceColor)
            .padding(16)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Unable to retrieve capabilities document")
                    .primary()
                Button("Try again") {
                    viewModel.retrieveWMSCapabilitiesDocument()
                }
                .buttonStyle(MaterialButtonStyle())
            }
            .padding(16)
            .background(Color.surfaceColor)
        }
    }
}

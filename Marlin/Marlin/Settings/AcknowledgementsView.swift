//
//  AcknowledgementsView.swift
//  Marlin
//
//  Created by Daniel Barela on 4/14/23.
//

import SwiftUI

struct AcknowledgementsView: View {
    var model: AcknowledgementModel = AcknowledgementModel()
    var body: some View {
        List {
            ForEach(model.acknowledgements.sorted(by: { one, two in
                one.title < two.title
            })) { acknowledgement in
                VStack(alignment: .leading) {
                    Text(acknowledgement.title)
                        .primary()
                    if let copyright = acknowledgement.copyright {
                        Text(copyright)
                            .overline()
                    }
                    if let license = acknowledgement.license {
                        Text(.init(license))
                            .secondary()
                    }
                }
            }
        }
        .tint(Color.primaryColorVariant)
        .listStyle(.plain)
        .listRowBackground(Color.surfaceColor)
        .background(Color.backgroundColor)
        .onAppear {
            Metrics.shared.appRoute(["about","acknowledgements"])
        }
    }
}

struct Acknowledgement: Identifiable, Hashable {
    var id: String { title }
    
    var title: String
    var copyright: String?
    var license: String?
}

class AcknowledgementModel {
    var acknowledgements: [Acknowledgement] = [
        Acknowledgement(title: "Exception Catcher", copyright: "Copyright (c) Sindre Sorhus <sindresorhus@gmail.com> (https://sindresorhus.com)", license: "This product includes software licensed under the [MIT license](https://raw.githubusercontent.com/sindresorhus/ExceptionCatcher/main/license).")
    ]
    init() {
        if let path = Bundle.main.url(forResource: "Settings", withExtension: "bundle")?.appendingPathComponent("Acknowledgements.plist"), let dictionary = NSDictionary(contentsOf: path) {
            for library in dictionary["PreferenceSpecifiers"] as? [Dictionary<String, Any>] ?? [] {
                if let title = library["Title"] as? String, !title.isEmpty, title != "Acknowledgements" {
                    acknowledgements.append(Acknowledgement(title: title, copyright: library["FooterText"] as? String, license: library["License"] as? String))
                }
            }
        }
    }
}

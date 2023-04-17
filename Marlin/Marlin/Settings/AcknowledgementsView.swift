//
//  AcknowledgementsView.swift
//  Marlin
//
//  Created by Daniel Barela on 4/14/23.
//

import SwiftUI

struct AcknowledgementsView: View {
    var acknowledgements: [Acknowledgement] = [
        Acknowledgement(
            title: "Alamofire",
            copyright: "Copyright (c) 2014-2022 Alamofire Software Foundation",
            license: "This product includes software licensed under the [MIT license](https://raw.githubusercontent.com/Alamofire/Alamofire/master/LICENSE)."),
        Acknowledgement(
            title: "Kingfisher",
            copyright: "Copyright (c) 2019 Wei Wang",
            license: "This product includes software licensed under the [MIT license](https://raw.githubusercontent.com/onevcat/Kingfisher/master/LICENSE)."),
        Acknowledgement(
            title: "GeoPackage",
            copyright: "Copyright (c) 2015 BIT Systems",
            license: "This product includes software licensed under the [MIT license](https://raw.githubusercontent.com/ngageoint/geopackage-ios/master/LICENSE)."),
        Acknowledgement(
            title: "MGRS",
            copyright: "Copyright (c) 2022 National Geospatial-Intelligence Agency",
            license: "This product includes software licensed under the [MIT license](https://raw.githubusercontent.com/ngageoint/mgrs-ios/master/LICENSE)."),
        Acknowledgement(
            title: "GARS",
            copyright: "Copyright (c) 2022 National Geospatial-Intelligence Agency",
            license: "This product includes software licensed under the [MIT license](https://raw.githubusercontent.com/ngageoint/gars-ios/master/LICENSE)."),
        Acknowledgement(
            title: "Matomo Tracker",
            license: "This product includes software licensed under the [MIT license](https://raw.githubusercontent.com/matomo-org/matomo-sdk-ios/develop/LICENSE.md)."),
        Acknowledgement(
            title: "SWXMLHash",
            copyright: "Copyright (c) 2014 David Mohundro",
            license: "This product includes software licensed under the [MIT license](https://raw.githubusercontent.com/drmohundro/SWXMLHash/main/LICENSE)."),
        Acknowledgement(
            title: "OHHTTPStubs",
            copyright: "Copyright (c) 2012 Olivier Halligon",
            license: "This product includes software licensed under the [MIT license](https://raw.githubusercontent.com/AliSoftware/OHHTTPStubs/master/LICENSE)."),
        Acknowledgement(
            title: "KIF",
            copyright: "Copyright 2011-2016 Square, Inc.",
            license: "This product includes software licensed under the [Apache License 2.0](https://raw.githubusercontent.com/kif-framework/KIF/master/LICENSE).")
    ]
    var body: some View {
        List {
            ForEach(acknowledgements.sorted(by: { one, two in
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

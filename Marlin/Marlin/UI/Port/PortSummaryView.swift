//
//  PortSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/17/22.
//

import SwiftUI
import MapKit

struct PortSummaryView: DataSourceSummaryView {
    @EnvironmentObject var bookmarkRepository: BookmarkRepositoryManager
    @EnvironmentObject var router: MarlinRouter
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false

    @EnvironmentObject var locationManager: LocationManager
    @State var distance: String?

    @StateObject var bookmarkViewModel: BookmarkViewModel = BookmarkViewModel()

    var port: PortListModel
    var showMoreDetails: Bool = false
    var showTitle: Bool = true
    var measurementFormatter: MeasurementFormatter {
        let measurementFormatter = MeasurementFormatter()
        measurementFormatter.unitOptions = .providedUnit
        measurementFormatter.unitStyle = .short
        measurementFormatter.numberFormatter.maximumFractionDigits = 2
        return measurementFormatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 8) {
                    
                    if showTitle {
                        Text("\(port.portName ?? "")")
                            .primary()
                    }
                    if let alternateName = port.alternateName {
                        Text("Alternate Name: \(alternateName)")
                            .secondary()
                    }
                    
                    Text("\(port.regionName ?? "")")
                        .secondary()
                }
                Spacer()
                if let distance = distance {
                    Text("\(distance)")
                        .secondary()
                }
            }
            bookmarkNotesView(port)
            DataSourceActions(
                moreDetails: showMoreDetails ? PortActions.Tap(portNumber: port.portNumber, path: $router.path) : nil,
                location: !showMoreDetails ? Actions.Location(latLng: port.coordinate) : nil,
                zoom: !showMoreDetails ? PortActions.Zoom(latLng: port.coordinate, itemKey: port.id) : nil,
                bookmark: port.canBookmark ? Actions.Bookmark(
                    itemKey: port.id,
                    bookmarkViewModel: bookmarkViewModel
                ) : nil,
                share: port.itemTitle
            )
        }
        .onAppear {
            bookmarkViewModel.repository = bookmarkRepository
            bookmarkViewModel.getBookmark(itemKey: port.id, dataSource: DataSources.port.key)

            if let currentLocation = locationManager.lastLocation {
                let metersMeasurement = NSMeasurement(
                    doubleValue: port.distanceTo(currentLocation),
                    unit: UnitLength.meters
                )
                let convertedMeasurement = metersMeasurement.converting(to: UnitLength.nauticalMiles)
                
                distance = """
                    \(measurementFormatter.string(from: convertedMeasurement)), \
                    \(currentLocation.coordinate.generalDirection(to: port.coordinate))
                """
            }
        }
        .onChange(of: locationManager.lastLocation) { lastLocation in
            if let currentLocation = lastLocation {
                let metersMeasurement = NSMeasurement(
                    doubleValue: port.distanceTo(currentLocation),
                    unit: UnitLength.meters
                )
                let convertedMeasurement = metersMeasurement.converting(to: UnitLength.nauticalMiles)
                
                distance = """
                    \(measurementFormatter.string(from: convertedMeasurement)), \
                    \(currentLocation.coordinate.generalDirection(to: port.coordinate))
                """
            }
        }
    }
}

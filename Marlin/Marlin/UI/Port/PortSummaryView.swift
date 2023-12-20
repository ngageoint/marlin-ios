//
//  PortSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/17/22.
//

import SwiftUI
import MapKit

struct PortSummaryView: DataSourceSummaryView {
    var showSectionHeader: Bool = false
    
    var showBookmarkNotes: Bool = false

    @EnvironmentObject var locationManager: LocationManager
    @State var distance: String?

    var port: PortModel
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
            DataSourceActionBar(data: port, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
        .onAppear {
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

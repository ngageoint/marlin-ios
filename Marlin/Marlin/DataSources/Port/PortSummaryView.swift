//
//  PortSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/17/22.
//

import SwiftUI
import MapKit

struct PortSummaryView: View {
    @EnvironmentObject var locationManager: LocationManager

    var port: Port
    var showMoreDetails: Bool = false
    var measurementFormatter: MeasurementFormatter
    
    init(port: Port, showMoreDetails: Bool = false) {
        self.port = port
        self.showMoreDetails = showMoreDetails
        self.measurementFormatter = MeasurementFormatter();
        measurementFormatter.unitOptions = .providedUnit;
        measurementFormatter.unitStyle = .short;
        measurementFormatter.numberFormatter.maximumFractionDigits = 2;
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    Text("\(port.portName ?? "")")
                        .font(Font.headline6)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.87)
                    Spacer()
                    if let currentLocation = locationManager.lastLocation {
                        let metersMeasurement = NSMeasurement(doubleValue: port.distanceTo(currentLocation), unit: UnitLength.meters);
                        let convertedMeasurement = metersMeasurement.converting(to: UnitLength.nauticalMiles);
                        
                        Text("\(measurementFormatter.string(from: convertedMeasurement)), \(currentLocation.coordinate.generalDirection(to: port.coordinate))")
                            .font(Font.body2)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.6)
                    }
                }
                if let alternateName = port.alternateName {
                    Text("Alternate Name: \(alternateName)")
                        .font(Font.body2)
                        .foregroundColor(Color.onSurfaceColor)
                        .opacity(0.6)
                }
                
                Text("\(port.regionName ?? "")")
                    .font(Font.body2)
                    .foregroundColor(Color.onSurfaceColor)
                    .opacity(0.6)
            }
            PortActionBar(port: port, showMoreDetailsButton: showMoreDetails, showFocusButton: !showMoreDetails)
        }
    }
}

//struct PortSummaryView_Previews: PreviewProvider {
//    static var previews: some View {
//        let context = PersistenceController.preview.container.viewContext
//        let port = try? context.fetchFirst(Port.self)
//        PortSummaryView(port: port!)
//    }
//}

//
//  SubmitReportView.swift
//  Marlin
//
//  Created by Daniel Barela on 10/24/22.
//

import SwiftUI

struct SubmitReportView: View {
    var body: some View {
        List {
            Section("Submit reports to NGA via these external links") {
                Link(destination: URL(string: "https://msi.nga.mil/submit-report/Observ-Report")!, label: {
                    HStack {
                        Image(systemName: "eye.fill")
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                        Text("Submit Observer Report")
                            .primary()
                        Spacer()
                    }
                })
                .accessibilityElement()
                .accessibilityLabel("Submit Observer Report")
                .environment(\.openURL, OpenURLAction { _ in
                    Metrics.shared.appRoute(["report", "observer"])
                    return .systemAction
                })
                
                Link(destination: URL(string: "https://msi.nga.mil/submit-report/MODU-Report")!, label: {
                    HStack {
                        if let image = DataSources.modu.image {
                            Image(uiImage: image)
                                .tint(Color.onSurfaceColor)
                                .opacity(0.60)
                        }
                        Text("Submit Mobile Offshore Drilling Unit (MODU) Movement Report")
                            .primary()
                        Spacer()
                    }
                })
                .accessibilityElement()
                .accessibilityLabel("Submit Mobile Offshore Drilling Unit (MODU) Movement Report")
                .environment(\.openURL, OpenURLAction { _ in
                    Metrics.shared.appRoute(["report", "modu"])
                    return .systemAction
                })
                
                Link(destination: URL(string: "https://msi.nga.mil/submit-report/Visit-Report")!, label: {
                    HStack {
                        if let image = DataSources.port.image {
                            Image(uiImage: image)
                                .tint(Color.onSurfaceColor)
                                .opacity(0.60)
                        }
                        Text("Submit US Navy Port Visit Report")
                            .primary()
                        Spacer()
                    }
                })
                .accessibilityElement()
                .accessibilityLabel("Submit US Navy Port Visit Report")
                .environment(\.openURL, OpenURLAction { _ in
                    Metrics.shared.appRoute(["report", "portVisit"])
                    return .systemAction
                })
                
                Link(destination: URL(string: "https://msi.nga.mil/submit-report/SHAR-Report")!, label: {
                    HStack {
                        Image(systemName: "ferry.fill")
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                        Text("Submit Ship Hostile Action Report")
                            .primary()
                        Spacer()
                    }
                })
                .accessibilityElement()
                .accessibilityLabel("Submit Ship Hostile Action Report")
                .environment(\.openURL, OpenURLAction { _ in
                    Metrics.shared.appRoute(["report", "hostileShip"])
                    return .systemAction
                })
            }
        }
        .navigationTitle("Submit Report")
        .navigationBarTitleDisplayMode(.inline)
        .listStyle(.grouped)
        .listRowBackground(Color.surfaceColor)
        .background(Color.backgroundColor)
        .foregroundColor(Color.onSurfaceColor)
        .onAppear {
            Metrics.shared.submitReportView()
        }
    }
}

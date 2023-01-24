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
                Link(destination: URL(string: "https://msi.nga.mil/submit-report/ASAM-Report")!, label: {
                    HStack {
                        if let image = Asam.image {
                            Image(uiImage: image)
                                .tint(Color.onSurfaceColor)
                                .opacity(0.60)
                        }
                        Text("Submit Anti-Shipping Activity Message (ASAM) Report")
                            .primary()
                        Spacer()
                    }
                })
                .accessibilityElement()
                .accessibilityLabel("Submit Anti-Shipping Activity Message (ASAM) Report")
                
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
                
                Link(destination: URL(string: "https://msi.nga.mil/submit-report/MODU-Report")!, label: {
                    HStack {
                        if let image = Modu.image {
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
                
                Link(destination: URL(string: "https://msi.nga.mil/submit-report/Visit-Report")!, label: {
                    HStack {
                        if let image = Port.image {
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

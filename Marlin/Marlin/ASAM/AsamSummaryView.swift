//
//  AsamSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import SwiftUI

struct AsamSummaryView: View {
    
    @EnvironmentObject var scheme: MarlinScheme
    
    var asam: Asam
    var showMoreDetails: Bool = false
    
    init(asam: Asam, showMoreDetails: Bool = false) {
        self.asam = asam
        self.showMoreDetails = showMoreDetails
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(asam.dateString ?? "")
                .font(Font(scheme.containerScheme.typographyScheme.overline))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.45)
            Text("\(asam.hostility ?? "")\(asam.hostility != nil ? ": " : "")\(asam.victim ?? "")")
                .font(Font(scheme.containerScheme.typographyScheme.headline6))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.87)
            Text(asam.asamDescription ?? "")
                .lineLimit(8)
                .font(Font(scheme.containerScheme.typographyScheme.body2))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.6)
            HStack(spacing:0) {
                if showMoreDetails {
                    MaterialButton(title: "More Details") {
                        print("more details")
                        NotificationCenter.default.post(name: .ViewAsam, object: self.asam)
                    }
                    .fixedSize()
                    .padding(.leading, -16)
                } else {
                    LatitudeLongitudeButton(latitude: asam.latitude ?? 0.0, longitude: asam.longitude ?? 0.0)
                        .fixedSize()
                        .padding(.leading, -16)
                }
                Spacer()
                MaterialButton(image: UIImage(systemName: "square.and.arrow.up")) {
                    print("share button")
                }.fixedSize()
                MaterialButton(image: UIImage(systemName: "scope")) {
                    print("share button")
                }.fixedSize().padding(.trailing, -16)
            }
        }
    }
}

struct AsamSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let asam = try? context.fetchFirst(Asam.self)
        return AsamSummaryView(asam: asam!)
    }
}

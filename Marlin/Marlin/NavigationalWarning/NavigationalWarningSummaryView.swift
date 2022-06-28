//
//  NavigationalWarningSummaryView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/23/22.
//

import SwiftUI

struct NavigationalWarningSummaryView: View {
    
    @EnvironmentObject var scheme: MarlinScheme
    
    var navigationalWarning: NavigationalWarning
    var showMoreDetails: Bool = false
    
    init(navigationalWarning: NavigationalWarning, showMoreDetails: Bool = false) {
        self.navigationalWarning = navigationalWarning
        self.showMoreDetails = showMoreDetails
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(navigationalWarning.dateString ?? "")
                .font(Font(scheme.containerScheme.typographyScheme.overline))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.45)
            Text("\(navigationalWarning.navAreaName) \(String(navigationalWarning.msgNumber))/\(String(navigationalWarning.msgYear)) (\(navigationalWarning.subregion ?? ""))")
                .font(Font(scheme.containerScheme.typographyScheme.headline6))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.87)
            Text("\(navigationalWarning.text ?? "")")
                .multilineTextAlignment(.leading)
                .lineLimit(8)
                .font(Font(scheme.containerScheme.typographyScheme.body2))
                .foregroundColor(Color(scheme.containerScheme.colorScheme.onSurfaceColor))
                .opacity(0.6)
            HStack(spacing:0) {
                if showMoreDetails {
                    MaterialButton(title: "More Details") {
                        print("more details")
                        NotificationCenter.default.post(name: .ViewNavigationalWarning, object: self.navigationalWarning)
                    }
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

struct NavigationalWarningSummaryView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let navigationalWarning = try? context.fetchFirst(NavigationalWarning.self)
        NavigationalWarningSummaryView(navigationalWarning: navigationalWarning!)
    }
}

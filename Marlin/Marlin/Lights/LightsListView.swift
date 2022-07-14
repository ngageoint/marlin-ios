//
//  LightsListView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/6/22.
//

import SwiftUI

struct LightsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var scheme: MarlinScheme
        
    @SectionedFetchRequest<String, Lights>(
        sectionIdentifier: \.sectionHeader!,
        sortDescriptors: [NSSortDescriptor(keyPath: \Lights.sectionHeader, ascending: true), NSSortDescriptor(keyPath: \Lights.featureNumber, ascending: true)],
        predicate: NSPredicate(format: "characteristicNumber = 1")
    )
    var sectionedLights: SectionedFetchResults<String, Lights>
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Lights.featureNumber, ascending: true), NSSortDescriptor(keyPath: \Lights.characteristicNumber, ascending:true)],
//        animation: .default)
//    private var lights: FetchedResults<Lights>
    
    var body: some View {
        NavigationView {
            VStack {
            List(sectionedLights) { section in
                
                Section(header: HStack {
                    Text(section.id)
                        .font(Font(scheme.containerScheme.typographyScheme.overline))
                        .foregroundColor(Color(scheme.containerScheme.colorScheme.onBackgroundColor))
                }) {

                    ForEach(section) { light in
                         
                        ZStack {
                            NavigationLink(destination: LightDetailView(featureNumber: light.featureNumber ?? "", volumeNumber: light.volumeNumber ?? "")
                                .navigationTitle("\(light.name ?? "")" )
                                .navigationBarTitleDisplayMode(.inline)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            
                            HStack {
                                if let featureNumber = light.featureNumber {
                                    LightSummaryView(light: light)
                                }
                            }
                            .padding(.all, 16)
                            .background(Color(scheme.containerScheme.colorScheme.surfaceColor))
                            .modifier(CardModifier())
                        }
                        
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                }
            }
            .navigationTitle("Lights")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.plain)
            .background(Color(scheme.containerScheme.colorScheme.backgroundColor))
            }
        }
    }
}

struct LightsListView_Previews: PreviewProvider {
    static var previews: some View {
        LightsListView()
    }
}

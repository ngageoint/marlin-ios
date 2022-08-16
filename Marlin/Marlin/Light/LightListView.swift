//
//  LightsListView.swift
//  Marlin
//
//  Created by Daniel Barela on 7/6/22.
//

import SwiftUI

struct LightsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
        
    @SectionedFetchRequest<String, Light>(
        sectionIdentifier: \.sectionHeader!,
        sortDescriptors: [NSSortDescriptor(keyPath: \Light.sectionHeader, ascending: true), NSSortDescriptor(keyPath: \Light.featureNumber, ascending: true)],
        predicate: NSPredicate(format: "characteristicNumber = 1")
    )
    var sectionedLights: SectionedFetchResults<String, Light>
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String? = nil
    
    var watchFocusedItem: Bool = false

    var body: some View {
        ZStack {
            if watchFocusedItem, let focusedLight = focusedItem.dataSource as? Light {
                NavigationLink(tag: "detail", selection: $selection) {
                    LightDetailView(featureNumber: focusedLight.featureNumber ?? "", volumeNumber: focusedLight.volumeNumber ?? "")
                        .navigationTitle("\(focusedLight.name ?? Light.dataSourceName)" )
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    EmptyView().hidden()
                }
                
                .isDetailLink(false)
                .onAppear {
                    selection = "detail"
                }
                .onChange(of: focusedItem.date) { newValue in
                    if watchFocusedItem, let _ = focusedItem.dataSource as? Light {
                        selection = "detail"
                    }
                }
            }
            List(sectionedLights) { section in
                
                Section(header: HStack {
                    Text(section.id)
                        .font(Font.overline)
                        .foregroundColor(Color.onBackgroundColor)
                }) {

                    ForEach(section) { light in
                         
                        ZStack {
                            NavigationLink(destination: LightDetailView(featureNumber: light.featureNumber ?? "", volumeNumber: light.volumeNumber ?? "")
                                .navigationTitle("\(light.name ?? Light.dataSourceName)" )
                                .navigationBarTitleDisplayMode(.inline)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            
                            HStack {
                                LightSummaryView(light: light)
                            }
                            .padding(.all, 16)
                            .background(Color.surfaceColor)
                            .modifier(CardModifier())
                        }
                        
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                }
            }
            .navigationTitle(Light.dataSourceName)
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.plain)
            .background(Color.backgroundColor)
        }
    }
}

struct LightsListView_Previews: PreviewProvider {
    static var previews: some View {
        LightsListView(focusedItem: ItemWrapper())
    }
}

//
//  DFRSListView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/30/22.
//

import SwiftUI

struct DFRSListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DFRSArea.areaName, ascending: true), NSSortDescriptor(keyPath: \DFRSArea.index, ascending: true)],
        predicate: NSPredicate(format: "areaNote != nil || indexNote != nil"),
        animation: .default)
    private var areas: FetchedResults<DFRSArea>
    
    @SectionedFetchRequest<String, DFRS>(
        sectionIdentifier: \.areaName!,
        sortDescriptors: [NSSortDescriptor(keyPath: \DFRS.areaName, ascending: true), NSSortDescriptor(keyPath: \DFRS.stationNumber, ascending: true)]
    )
    var sectionedDFRS: SectionedFetchResults<String, DFRS>
    @ObservedObject var focusedItem: ItemWrapper
    @State var selection: String? = nil
    
    var watchFocusedItem: Bool = false
    
    var body: some View {
        ZStack {
            if watchFocusedItem, let dfrs = focusedItem.dataSource as? DFRS {
                NavigationLink(tag: "detail", selection: $selection) {
                    dfrs.detailView
                        .navigationTitle("\(dfrs.stationName ?? DFRS.dataSourceName)" )
                        .navigationBarTitleDisplayMode(.inline)
                        .onDisappear {
                            focusedItem.dataSource = nil
                        }
                } label: {
                    EmptyView().hidden()
                }
                
                .isDetailLink(false)
                .onAppear {
                    selection = "detail"
                }
                .onChange(of: focusedItem.date) { newValue in
                    if watchFocusedItem, let _ = focusedItem.dataSource as? DFRS {
                        selection = "detail"
                    }
                }
                
            }
            List(sectionedDFRS) { section in
                
                Section(header: HStack {
                    let areaNotes = areas.reduce("") { result, area in
                        if area.areaName == section.id {
                            var newResult = "\(result)"
                            if newResult == "" {
                                newResult = "\(area.areaNote ?? "")\n\(area.indexNote ?? "")"
                            } else {
                                newResult = "\(newResult)\n\(area.indexNote ?? "")"
                            }
                            return newResult
                        }
                        return result
                    }
                    VStack(alignment: .leading) {
                        Text(section.id)
                            .font(Font.overline)
                            .foregroundColor(Color.onBackgroundColor)
                        if areaNotes != "" {
                            Text(areaNotes)
                                .font(Font.overline)
                                .foregroundColor(Color.onBackgroundColor)
                        }
                    }
                }) {
                    
                    ForEach(section) { dfrs in
                        
                        ZStack {
                            NavigationLink(destination: dfrs.detailView
                                .navigationTitle("\(dfrs.stationName ?? DFRS.dataSourceName)" )
                                .navigationBarTitleDisplayMode(.inline)) {
                                    EmptyView()
                                }
                                .opacity(0)
                            
                            HStack {
                                dfrs.summaryView()
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
            .navigationTitle(DFRS.dataSourceName)
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.plain)
            .background(Color.backgroundColor)
        }
    }
}

struct DFRSListView_Previews: PreviewProvider {
    static var previews: some View {
        DFRSListView(focusedItem: ItemWrapper())
    }
}

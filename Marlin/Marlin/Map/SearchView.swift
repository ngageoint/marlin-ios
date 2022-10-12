//
//  SearchView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//

import SwiftUI
import MapKit
import Combine

struct SearchView: View {
    @AppStorage("searchEnabled") var searchEnabled: Bool = false
    @State var search: String = ""
    let searchPublisher = PassthroughSubject<String, Never>()
    @AppStorage("searchExpanded") var searchExpanded: Bool = false
    @ObservedObject var mapState: MapState
        
    var body: some View {
        if searchEnabled {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .frame(width: 24, height: 24, alignment: .center)
                        .onTapGesture {
                            searchExpanded.toggle()
                        }
                    Group {
                        TextField("Search", text: $search)
                            .foregroundColor(Color.onSurfaceColor)
                            .frame(maxWidth: searchExpanded ? .infinity : 0)
                            .onChange(of: search) { search in
                                searchPublisher.send(search)
                            }
                            .onReceive(
                                searchPublisher
                                    .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                            ) { debouncedSearch in
                                print(debouncedSearch)
                                performSearch(searchText: debouncedSearch)
                            }
                            .overlay(alignment: .trailing) {
                                if !(mapState.searchResults?.isEmpty ?? true) {
                                    Text("clear")
                                        .padding(.trailing, 8)
                                        .onTapGesture {
                                            search = ""
                                            mapState.searchResults = []
                                        }
                                    
                                        .padding(.trailing, 0)
                                }
                            }
                    }
                    .animation(.default, value: searchExpanded)
                    .frame(minWidth: 0, maxWidth: searchExpanded ? .infinity : 0)
                }
                .padding(.top, 8)
                .padding(.bottom, 8)
                .padding(.leading, !(mapState.searchResults?.isEmpty ?? false) && !searchExpanded ? 8 : 0)
                if let searchResults = mapState.searchResults, !searchResults.isEmpty {
                    if searchExpanded {
                        Divider()
                            .padding(.top, 4)
                    }
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(searchResults, id: \.self) { searchResult in
                                VStack(alignment: .leading) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("**\(searchResult.name ?? "")**")
                                                .primary()
                                            Text("\(searchResult.placemark.title ?? "")")
                                                .secondary()
                                            Text("\(searchResult.placemark.location?.coordinate.latitude ?? 0.0),\(searchResult.placemark.location?.coordinate.longitude ?? 0.0)")
                                        }
                                        Spacer()
                                        Button(action: {
                                            mapState.center = MKCoordinateRegion(center: searchResult.placemark.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
                                        }) {
                                            Label(
                                                title: {},
                                                icon: { Image(systemName: "scope")
                                                        .renderingMode(.template)
                                                        .foregroundColor(Color.primaryColorVariant)
                                                })
                                        }
                                    }
                                    .padding([.leading, .trailing], 8)
                                    Divider()
                                }
                            }
                        }
                    }
                    .padding([.top, .bottom], 4)
                    .frame(minWidth: 40, maxWidth: searchExpanded ? .infinity : 40, maxHeight: searchExpanded ? 150 : 0)
                    .animation(.default, value: searchExpanded)
                }
            }
            .frame(minWidth: 40, maxWidth: searchExpanded ? .infinity : 40, minHeight: 40)
            .padding([.leading, .trailing], searchExpanded ? 8 : 0)
            .font(Font.body2)
            .foregroundColor(Color.primaryColorVariant)
            .background(
                RoundedRectangle(cornerRadius: 20).fill(Color.surfaceColor).shadow(color: Color(.sRGB, white: 0, opacity: 0.4), radius: 3, x: 0, y: 4)
                    .animation(.default, value: searchExpanded)
            )
            .offset(x: 8, y: 16)
        }
    }
    
    func performSearch(searchText: String) {
        var realSearch = searchText
        // check if they maybe entered coordinates
        if let location = CLLocationCoordinate2D(coordinateString: searchText) {
            NSLog("This is a location")
            // just send the location to the search
            realSearch = "\(location.latitude), \(location.longitude)"
        }
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = realSearch
        
        // Set the region to an associated map view's region.
        if let region = mapState.center {
            searchRequest.region = region
        }
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            guard let response = response else {
                mapState.searchResults = []
                // Handle the error.
                return
            }
            
            mapState.searchResults = response.mapItems
        }
    }
}

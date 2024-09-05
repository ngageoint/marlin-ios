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
    @EnvironmentObject var searchRepository: SearchRepository
    @AppStorage("coordinateDisplay") var coordinateDisplay: CoordinateDisplayType = .latitudeLongitude

    @State var search: String = ""
    @FocusState private var searchFocused: Bool
    let searchPublisher = PassthroughSubject<String, Never>()
    @AppStorage("searchExpanded") var searchExpanded: Bool = false
    @ObservedObject var mapState: MapState
        
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18))
                    .frame(width: 24, height: 24, alignment: .center)
                    .onTapGesture {
                        searchExpanded.toggle()
                        searchFocused = searchExpanded
                        if searchExpanded {
                            Metrics.shared.searchView()
                        }
                    }
                    .accessibilityElement()
                    .accessibilityLabel("\(searchExpanded ? "Collapse" : "Expand") Search")
                Group {
                    TextField("Search", text: $search)
                        .focused($searchFocused)
                        .textInputAutocapitalization(.never)
                        .foregroundColor(Color.primaryColorVariant)
                        .accentColor(Color.primaryColorVariant)
                        .tint(Color.primaryColorVariant)
                        .submitLabel(SubmitLabel.done)
                        .onSubmit {
                            searchFocused.toggle()
                            searchPublisher.send(search)
                        }
                        .frame(maxWidth: searchExpanded ? .infinity : 0)
                        .onChange(of: search) { search in
                            searchPublisher.send(search)
                        }
                        .onReceive(
                            searchPublisher
                                .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
                        ) { debouncedSearch in
                            print(debouncedSearch)
                            Task {
                                await performSearch(searchText: debouncedSearch)
                            }
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
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel("Search Field")
                }
                .animation(.default, value: searchExpanded)
                .frame(minWidth: 0, maxWidth: searchExpanded ? .infinity : 0)
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
            .padding(.leading, !(mapState.searchResults?.isEmpty ?? true) && !searchExpanded ? 8 : 0)
            if let searchResults = mapState.searchResults, !searchResults.isEmpty {
                if searchExpanded {
                    Divider()
                        .padding(.top, 4)
                }
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(searchResults) { searchResult in
                            VStack(alignment: .leading) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("**\(searchResult.displayName)**")
                                            .primary()
                                            .accessibilityElement()
                                            .accessibilityLabel(searchResult.displayName)
//                                        Text("\(searchResult.placemark.title ?? "")")
//                                            .secondary()
                                            Text(coordinateDisplay.format(coordinate: searchResult.coordinate)
                                            )
                                            .onTapGesture {
                                                UIPasteboard.general.string =
                                                coordinateDisplay.format(coordinate: searchResult.coordinate)
                                                NotificationCenter.default.post(
                                                    name: .SnackbarNotification,
                                                    object: SnackbarNotification(
                                                        snackbarModel: SnackbarModel(
                                                            message: """
                                                            Location \
                                                            \(coordinateDisplay.format(coordinate: searchResult.coordinate)) \
                                                            copied to clipboard
                                                            """
                                                        )
                                                    )
                                                )
                                            }
                                            .accessibilityElement()
                                            .accessibilityLabel("Location")
                                    }
                                    Spacer()
                                    Button(
                                        action: {
                                            mapState.center = MKCoordinateRegion(
                                                center: searchResult.coordinate,
                                                latitudinalMeters: 10000,
                                                longitudinalMeters: 10000
                                            )
                                        },
                                        label: {
                                            Label(
                                                title: {},
                                                icon: { Image(systemName: "scope")
                                                        .renderingMode(.template)
                                                        .foregroundColor(Color.primaryColorVariant)
                                                })
                                        }
                                    )
                                    .accessibilityElement()
                                    .accessibilityLabel("focus")
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
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.mapButtonColor)
                .shadow(color: Color(.sRGB, white: 0, opacity: 0.4), radius: 3, x: 0, y: 4)
                .animation(.default, value: searchExpanded)
        )
    }
    
    func performSearch(searchText: String) async {
        let result = await searchRepository.performSearch(searchText: searchText, region: mapState.center)

        await MainActor.run {
            mapState.searchResults = result
        }
    }
}

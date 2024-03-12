//
//  NominatimSearchProvider.swift
//  Marlin
//
//  Created by Joshua Nelson on 1/30/24.
//

import Foundation
import MapKit
import Alamofire

struct NominatimPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case items
    }
    let items: [SearchResultModel]

    init(items: [SearchResultModel]) {
        self.items = items
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var items: [SearchResultModel] = []
        while !container.isAtEnd {
            if let item = try? container.decode(Throwable<SearchResultModel>.self) {
                if let itemResult = try? item.result.get() {
                    items.append(itemResult)
                }
            }
        }
        self.items = items
    }
}

class NominatimSearchProvider: SearchProvider {
    func performSearch(
        searchText rawSearchTerm: String,
        region: MKCoordinateRegion?,
        onCompletion: @escaping ([SearchResultModel]) -> Void) {
            var searchTerm = rawSearchTerm
            let parsedLocation = CLLocationCoordinate2D(coordinateString: searchTerm)
            if let location = parsedLocation {
                searchTerm = "\(location.latitude), \(location.longitude)"
            }
            let request = NominatimService.textSearch(query: searchTerm)
            let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            MSI.shared.session.request(request)
                .validate()
                .responseDecodable(
                    of: NominatimPropertyContainer.self,
                    queue: queue,
                    decoder: decoder
                ) { response in
                    debugPrint(response)
                    switch response.result {
                    case .success(let container):
                        var models: [SearchResultModel] = container.items
                        //                        .map { item in
                        //                        let placemark = MKPlacemark(
                        //                            coordinate: CLLocationCoordinate2D(
                        //                                latitude: Double(item.lat) ?? 0.0,
                        //                                longitude: Double(item.lon) ?? 0.0)
                        //                        )
                        //                        // XXX: placemark title seems to be getting set to United States sometimes
                        //                        let mapItem = MKMapItem(placemark: placemark)
                        //                        mapItem.name = item.displayName
                        //                        return mapItem
                        //                    } ?? []

                        if let location = parsedLocation {
                            models.append(SearchResultModel(
                                displayName: "\(location.latitude), \(location.longitude)",
                                lat: "\(location.latitude)",
                                lon: "\(location.longitude)"
                            ))
                            //                        let coordPlacemark = MKPlacemark(coordinate: location)
                            //                        let coordMapItem = MKMapItem(placemark: coordPlacemark)
                            //                        coordMapItem.name = "\(location.latitude), \(location.longitude)"
                            //                        mapItems.insert(coordMapItem, at: 0)
                        }
                        onCompletion(models)
                    case .failure:
                        onCompletion([])
                    }
                }
        }

    func performSearchNear(
        region: MKCoordinateRegion?,
        zoom: Int,
        onCompletion: @escaping ([SearchResultModel]) -> Void
    ) {
        guard let region = region else {
            onCompletion([])
            return
        }
        // zoom + 3 "feels" better than zoom
        let request = NominatimService.reverse(
            lat: region.center.latitude,
            lon: region.center.longitude,
            zoom: zoom + 3
        )
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        MSI.shared.session.request(request)
            .validate()
            .responseDecodable(of: SearchResultModel.self, queue: queue, decoder: decoder) { response in
                debugPrint(response)
                switch response.result {
                case .success(let item):
                    print("item \(item)")
//                    let placemark = MKPlacemark(
//                        coordinate: CLLocationCoordinate2D(
//                            latitude: Double(item.lat) ?? 0.0,
//                            longitude: Double(item.lon) ?? 0.0)
//                    )
//                    let mapItem = MKMapItem(placemark: placemark)
//                    mapItem.name = item.displayName
                    onCompletion([item])
                case .failure(let error):
//                    let coordPlacemark = MKPlacemark(coordinate: region.center)
//                    let coordMapItem = MKMapItem(placemark: coordPlacemark)
//                    coordMapItem.name = "\(region.center.latitude), \(region.center.longitude)"
//                    onCompletion([coordMapItem])

                    onCompletion([SearchResultModel(
                        displayName: "\(region.center.latitude), \(region.center.longitude)",
                        lat: "\(region.center.latitude)",
                        lon: "\(region.center.longitude)"
                    )])
                }

            }
    }
}

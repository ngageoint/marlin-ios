//
//  MapImageTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/29/22.
//

import XCTest
import MapKit

@testable import Marlin

class MockMapImage: MapImage, DataSource {
    static var cacheTiles: Bool = false
    
    static var properties: [Marlin.DataSourceProperty] = []
    
    static var defaultSort: [Marlin.DataSourceSortParameter] = []
    
    static var defaultFilter: [Marlin.DataSourceFilterParameter] = []
    
    static var isMappable: Bool = true
    
    static var dataSourceName: String = "mock"
    
    static var fullDataSourceName: String = "mock"
    
    static var key: String = "mock"
    
    static var color: UIColor = UIColor.black
    
    static var imageName: String?
    
    static var systemImageName: String? = "face.smiling"
    
    var color: UIColor = UIColor.black
    
    static var imageScale: CGFloat = 0.5
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }
    
    func mapImage(marker: Bool, zoomLevel: Int, tileBounds3857: Marlin.MapBoundingBox?, context: CGContext?) -> [UIImage] {
        return defaultMapImage(marker: marker, zoomLevel: zoomLevel, tileBounds3857: tileBounds3857, context: context, tileSize: 512.0)
    }
    
    var latitude: Double = 1.0
    
    var longitude: Double = 1.0
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 1.0, longitude: 1.0)
}

final class MapImageTests: XCTestCase {

    func testZoomLevelMapImages() {
        let mock = MockMapImage()
        
        var circleSize: CGSize = .zero
        var imageSize: CGSize = .zero

        for i in 1...18 {
            let images = mock.mapImage(marker: false, zoomLevel: i, tileBounds3857: MapBoundingBox(swCorner: (x:-10, y:-10), neCorner: (x: 10, y:10)), context: nil)
            XCTAssertNotNil(images)
            XCTAssertEqual(images.count, 2)
            XCTAssertGreaterThan(images[0].size.height, circleSize.height)
            XCTAssertGreaterThan(images[0].size.width, circleSize.width)
            circleSize = images[0].size
            XCTAssertGreaterThan(images[0].size.height, imageSize.height)
            XCTAssertGreaterThan(images[0].size.width, imageSize.width)
            imageSize = images[0].size
            print("xxx circle size \(circleSize)")
            print("xxx image size \(images[1].size)")
        }
    }

    
}

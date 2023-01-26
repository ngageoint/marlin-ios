//
//  CLLocationCoordinate2DExtensionsTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/24/23.
//

import XCTest
import CoreLocation

@testable import Marlin

final class CLLocationCoordinate2DExtensionsTests: XCTestCase {

    func testParseCoordinateStringToDMSString() {
        XCTAssertNil(CLLocationCoordinate2D.parseToDMSString(nil))
        
        var coordinates = "112230N"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"11° 22' 30\" N")
        
        coordinates = "112230"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"11° 22' 30\" ")
        
        coordinates = "30N"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"30° N")
        
        coordinates = "3030N"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"30° 30' N")
        
        coordinates = "purple"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"E")
        
        coordinates = ""
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"")
        
        coordinates = "N 11 ° 22'30 \""
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"11° 22' 30\" N")
        
        coordinates = "N 11 ° 22'30.36 \""
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"11° 22' 30\" N")
        
        coordinates = "112233.99N"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"11° 22' 34\" N")
        
        coordinates = "11.999999N"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"12° 00' 00\" N")
        
        coordinates = "N 11 ° 22'30.remove \""
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"11° 22' 30\" N")
        
        coordinates = "11 ° 22'30 \"N"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"11° 22' 30\" N")
        
        coordinates = "11° 22'30 N"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"11° 22' 30\" N")
        
        coordinates = "11"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"11° ")
        
        coordinates = "11.4584"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates, addDirection: true, latitude: true),"11° 27' 30\" N")
        
        coordinates = "-11.4584"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates, addDirection: true, latitude: true),"11° 27' 30\" S")
        
        coordinates = "11.4584"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates, addDirection: true),"11° 27' 30\" E")
        
        coordinates = "-11.4584"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates, addDirection: true),"11° 27' 30\" W")
        
        coordinates = "11.4584"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates, addDirection: true, latitude: true),"11° 27' 30\" N")
        
        coordinates = "-11.4584"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates, addDirection: true, latitude: true),"11° 27' 30\" S")
        
        coordinates = "0151545W"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"15° 15' 45\" W")
        
        coordinates = "113000W"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"11° 30' 00\" W")
        
        coordinates = "W 15 ° 15'45"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"15° 15' 45\" W")
        
        coordinates = "15 ° 15'45\" W"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"15° 15' 45\" W")
        
        coordinates = "015° 15'45 W"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"15° 15' 45\" W")
        
        coordinates = "15.6827"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"15° 40' 58\" ")
        
        coordinates = "-15.6827"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"15° 40' 58\" ")
        
        coordinates = "15.6827"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates, addDirection: true),"15° 40' 58\" E")
        
        coordinates = "-15.6827"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates, addDirection: true),"15° 40' 58\" W")
        
        coordinates = "113000NNNN"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"11° 30' 00\" N")
        
        coordinates = "0.186388888888889"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates, addDirection: true),"0° 11' 11\" E")
        
        coordinates = "0° 11' 11\" N"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"0° 11' 11\" N")
        
        coordinates = "705600N"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"70° 56' 00\" N")
        
        coordinates = "70° 560'"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"7° 06' 00\" ")
        
        coordinates = "17-30-00N"
        XCTAssertEqual(CLLocationCoordinate2D.parseToDMSString(coordinates),"17° 30' 00\" N")
    }
    
    func testCreateCoordinate() {
        var coordinates = "112230N 0151545W"
        var parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,11.375)
        XCTAssertEqual(parsed?.longitude,-15.2625)

        coordinates = "N 11 ° 22'30 \"- W 15 ° 15'45"
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,11.375)
        XCTAssertEqual(parsed?.longitude,-15.2625)

        coordinates = "11 ° 22'30 \"N - 15 ° 15'45\" W"
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,11.375)
        XCTAssertEqual(parsed?.longitude,-15.2625)

        coordinates = "11° 22'30 N 015° 15'45 W"
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,11.375)
        XCTAssertEqual(parsed?.longitude,-15.2625)

        coordinates = "N 11° 22'30 W 015° 15'45 "
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,11.375)
        XCTAssertEqual(parsed?.longitude,-15.2625)

        coordinates = "11.4584 15.6827"
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,11.4584)
        XCTAssertEqual(parsed?.longitude,15.6827)

        coordinates = "-11.4584 15.6827"
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,-11.4584)
        XCTAssertEqual(parsed?.longitude,15.6827)

        coordinates = "11.4584 -15.6827"
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,11.4584)
        XCTAssertEqual(parsed?.longitude,-15.6827)

        coordinates = "11.4584, 15.6827"
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,11.4584)
        XCTAssertEqual(parsed?.longitude,15.6827)

        coordinates = "-11.4584, 15.6827"
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,-11.4584)
        XCTAssertEqual(parsed?.longitude,15.6827)

        coordinates = "11.4584, -15.6827"
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,11.4584)
        XCTAssertEqual(parsed?.longitude,-15.6827)

        coordinates = "11.4584"
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertNil(parsed)
        
        coordinates = "17-30-00N 101-15-00W"
        parsed = CLLocationCoordinate2D(coordinateString: coordinates)
        XCTAssertEqual(parsed?.latitude,17.5)
        XCTAssertEqual(parsed?.longitude,-101.25)
    }
    
    func testValidate() {
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: nil))
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: "NS1122N"))
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: "002233.NS"))
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: "ABCDEF.NS"))
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: "11NSNS.1N"))
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: "1111NS.1N"))
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: "113000NNN"))
        
        var validString = "112233N"
        XCTAssertTrue(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: validString))
        validString = "002233N"
        XCTAssertTrue(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: validString))
        validString = "02233N"
        XCTAssertTrue(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: validString))
        validString = "12233N"
        XCTAssertTrue(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: validString))
        validString = "002233S"
        XCTAssertTrue(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: validString))
        validString = "002233.2384S"
        XCTAssertTrue(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: validString))
        validString = "1800000E"
        XCTAssertTrue(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: validString))
        validString = "1800000W"
        XCTAssertTrue(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: validString))
        validString = "900000S"
        XCTAssertTrue(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: validString))
        validString = "900000N"
        XCTAssertTrue(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: validString))
        
        var invalidString = "2233N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "33N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "2N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "233N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = ".123N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = ""
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        
        invalidString = "2233W"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = "33W"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = "2W"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = "233W"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = "W"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = ".123W"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = ""
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        
        invalidString = "112233"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "1a2233N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "1a2233N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "11a233N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "1122a3N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "912233N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "-112233N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "116033N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "112260N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        
        invalidString = "1812233W"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = "-112233W"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = "002233E"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "002233N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = "1800001E"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = "1800000.1E"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = "1800001W"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = "1800000.1W"
        XCTAssertFalse(CLLocationCoordinate2D.validateLongitudeFromDMS(longitude: invalidString))
        invalidString = "900001N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "900000.1N"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "900001S"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "900000.1S"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "108900S"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
        invalidString = "100089S"
        XCTAssertFalse(CLLocationCoordinate2D.validateLatitudeFromDMS(latitude: invalidString))
    }
}

//
//  MockBundle.swift
//  MarlinTests
//
//  Created by Daniel Barela on 11/9/23.
//

import Foundation
import OHHTTPStubs

class MockBundle: Bundle {
    var mockPath: String?
    var tempFileContents: [String : Any]?
    
    override func url(forResource name: String?, withExtension ext: String?) -> URL? {
        if let mockPath = mockPath, let path = OHPathForFile(mockPath, type(of: self)) {
            return URL(fileURLWithPath: path)
        } else if let tempFileContents = tempFileContents {
            let tempFileURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp.json", conformingTo: .json)
            if let jsonData = try? JSONSerialization.data(withJSONObject: tempFileContents, options: []) {
                FileManager.default.createFile(atPath: tempFileURL.path(), contents: jsonData)
                return tempFileURL
            }
        }
        return nil
    }
}

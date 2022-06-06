//
//  TestHelper.swift
//  MarlinTests
//
//  Created by Daniel Barela on 6/6/22.
//

import Foundation
@testable import Marlin

class TestHelpers {
    static func clearData() {
        let asamsTruncated = PersistenceController.shared.container.viewContext.truncateAll(Asam.self)
        print("Asams truncated? \(asamsTruncated)")
    }
}

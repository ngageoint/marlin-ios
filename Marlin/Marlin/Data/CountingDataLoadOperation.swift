//
//  DataLoadOperation.swift
//  Marlin
//
//  Created by Daniel Barela on 12/21/23.
//

import Foundation

protocol CountingDataLoadOperation: Operation {
    var count: Int { get }
}

//
//  StringExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 3/9/23.
//

import Foundation

extension String {
    var isValidURL: Bool {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector?.firstMatch(
            in: self,
            options: [],
            range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}

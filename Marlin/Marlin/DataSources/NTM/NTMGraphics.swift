//
//  NTMGraphics.swift
//  Marlin
//
//  Created by Daniel Barela on 11/15/22.
//

import Foundation
import UIKit

struct NTMGraphicsPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case ntmGraphics
    }
    let ntmGraphics: [NTMGraphics]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        ntmGraphics = try container.decode([Throwable<NTMGraphics>].self, forKey: .ntmGraphics).compactMap {
            let r = try? $0.result.get()
            return r
        }
    }
}

/**
 {
 "chartNumber": "83476",
 "priceCategory": "A",
 "subregion": 83,
 "noticeNumber": 202229,
 "noticeYear": 2022,
 "noticeWeek": 29,
 "graphicType": "Chartlet",
 "seqNum": 1,
 "fileName": "C83476_01_A_20220624115520_U.jpg",
 "fileSize": "324530"
 },
 {
 */

struct NTMGraphics: Codable, Hashable, Identifiable {
    var id: String { fileName ?? "" }

    static func == (lhs: NTMGraphics, rhs: NTMGraphics) -> Bool {
        return lhs.fileName == rhs.fileName
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fileName)
    }

    let chartNumber: String?
    let priceCategory: String?
    let subregion: Int?
    let noticeNumber: Int?
    let noticeYear: Int?
    let noticeWeek: Int?
    let graphicType: String?
    let seqNum: Int?
    let fileName: String?
    let fileSize: Int?
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.chartNumber = try? values.decode(String.self, forKey: .chartNumber)
        self.priceCategory = try? values.decode(String.self, forKey: .priceCategory)
        self.subregion = try? values.decode(Int.self, forKey: .subregion)
        self.noticeNumber = try? values.decode(Int.self, forKey: .noticeNumber)
        self.noticeYear = try? values.decode(Int.self, forKey: .noticeYear)
        self.noticeWeek = try? values.decode(Int.self, forKey: .noticeWeek)
        self.graphicType = try? values.decode(String.self, forKey: .graphicType)
        self.seqNum = try? values.decode(Int.self, forKey: .seqNum)
        self.fileName = try? values.decode(String.self, forKey: .fileName)
        let rawFileSize = try? values.decode(String.self, forKey: .fileSize)
        self.fileSize = Int(rawFileSize ?? "")
    }
    
    var graphicUrl: String {
        get {
            var url = "\(MSIRouter.baseURLString)/publications/download?key=\(MSIRouter.ntmGraphicKeyBase)/\(noticeNumber ?? 0)/chartlets/\(fileName ?? "")&type=view"
            if graphicType == "Depth Tab" {
                url = "\(MSIRouter.baseURLString)/publications/download?key=\(MSIRouter.ntmGraphicKeyBase)/\(noticeNumber ?? 0)/depthtabs/\(fileName ?? "")&type=view"
            } else if graphicType == "Note" {
                url = "\(MSIRouter.baseURLString)/publications/download?key=\(MSIRouter.ntmGraphicKeyBase)/\(noticeNumber ?? 0)/notes/\(fileName ?? "")&type=view"
            }
            return url
        }
    }
}

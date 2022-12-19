//
//  NTM.swift
//  Marlin
//
//  Created by Daniel Barela on 11/10/22.
//

import Foundation
import UIKit

struct ChartCorrectionPropertyContainer: Decodable {
    private enum CodingKeys: String, CodingKey {
        case chartCorr
    }
    let chartCorr: [ChartCorrection]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        chartCorr = try container.decode([Throwable<ChartCorrection>].self, forKey: .chartCorr).compactMap {
            let r = try? $0.result.get()
            return r
        }
    }
}

struct ChartCorrection: Decodable, Hashable, Identifiable, DataSource {
    static var properties: [DataSourceProperty] = [
        DataSourceProperty(name: "Notice Number", key: "currNoticeNum", type: .int, requiredInFilter: false),
        DataSourceProperty(name: "Location", key: "location", type: .location, requiredInFilter: true)
    ]
    static var defaultSort: [DataSourceSortParameter] = []
    static var defaultFilter: [DataSourceFilterParameter] = [
        DataSourceFilterParameter(property: DataSourceProperty(name: "Location", key: "location", type: .location), comparison: .nearMe, valueInt: 2500)
    ]
    static var isMappable: Bool = false
    static var dataSourceName: String = "Chart Corrections"
    static var fullDataSourceName: String = "Chart Corrections"
    static var key: String = "chartCorrection"
    static var color: UIColor = NoticeToMariners.color
    static var imageName: String?
    static var systemImageName: String?
    var color: UIColor = NoticeToMariners.color
    static var imageScale: CGFloat = 1.0
    static var dateFormatter: DateFormatter = DateFormatter()
    
    static func postProcess() {
    }
    
    var id: Date { date }
    static func == (lhs: ChartCorrection, rhs: ChartCorrection) -> Bool {
        return lhs.date == rhs.date
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
    }
    
    private enum CodingKeys: String, CodingKey {
        case chartId
        case chartNumber
        case intlNumber
        case starred
        case limDist
        case correctionType
        case currNoticeNum
        case noticeAction
        case editionNumber
        case editionDate
        case lastNoticeNum
        case correctionText
        case authority
        case region
        case subregion
        case portCode
        case classification
        case priceCategory
        case date
    }
    
    struct CorrectionText: Codable {
        let correction: [Correction]?
    }
    struct Correction: Codable, Hashable, Identifiable {
        public var id: Int {
            self.hashValue
        }
        
        let action: String?
        let text: String?
    }
    let chartId: Int?
    let chartNumber: String?
    let intlNumber: String?
    let starred: Bool?
    let limDist: Bool?
    let noticeYear: Int
    let noticeWeek: Int
    let correctionType: String?
    let currNoticeNum: String?
    let noticeAction: String?
    let editionNumber: String?
    let editionDate: String?
    let lastNoticeNum: String?
    let correctionText: CorrectionText?
    let authority: String?
    let region: String?
    let subregion: String?
    let portCode: Int?
    let classification: String?
    let priceCategory: String?
    let date: Date = Date()
    let location: String? = nil
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.chartId = try? values.decode(Int.self, forKey: .chartId)
        self.chartNumber = try? values.decode(String.self, forKey: .chartNumber)
        self.intlNumber = try? values.decode(String.self, forKey: .intlNumber)
        self.correctionType = try? values.decode(String.self, forKey: .correctionType)
        self.currNoticeNum = try? values.decode(String.self, forKey: .currNoticeNum)
        self.noticeAction = try? values.decode(String.self, forKey: .noticeAction)
        self.editionNumber = try? values.decode(String.self, forKey: .editionNumber)
        self.editionDate = try? values.decode(String.self, forKey: .editionDate)
        self.lastNoticeNum = try? values.decode(String.self, forKey: .lastNoticeNum)
        self.authority = try? values.decode(String.self, forKey: .authority)
        self.region = try? values.decode(String.self, forKey: .region)
        self.subregion = try? values.decode(String.self, forKey: .subregion)
        self.portCode = try? values.decode(Int.self, forKey: .portCode)
        self.classification = try? values.decode(String.self, forKey: .classification)
        self.priceCategory = try? values.decode(String.self, forKey: .priceCategory)
        self.starred = try? values.decode(Bool.self, forKey: .starred)
        self.limDist = try? values.decode(Bool.self, forKey: .limDist)
        self.correctionText = try? values.decode(CorrectionText.self, forKey: .correctionText)
        if let currNoticeNum = self.currNoticeNum {
            let split = currNoticeNum.split(separator: "/")
            if split.count == 2 {
                noticeWeek = Int(split[0]) ?? 0
                noticeYear = Int(split[1]) ?? 0
            } else {
                noticeYear = 0
                noticeWeek = 0
            }
        } else {
            noticeYear = 0
            noticeWeek = 0
        }
    }
}

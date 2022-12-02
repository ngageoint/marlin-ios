//
//  NTMListView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/10/22.
//

import Foundation
import SwiftUI
import Alamofire
import sf_ios

struct ChartCorrectionList: View {
    
    @State var results: [String? : [ChartCorrection]] = [:]
    @State var tappedItem: ChartCorrection?
    @State private var showDetail = false
    @State var loading = false
    @State var queryError: String?
    @State var urlString: String?
    
    private let columns = [
        GridItem(.fixed(100)),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    let sortedKeys: [String] = results.keys.sorted {
                        return $0 ?? "" < $1 ?? ""
                    }.compactMap { $0 }
                    ForEach(Array(sortedKeys), id: \.self) { key in
//                        NavigationLink {
//                            Text("detail")
//                        } label: {
                            if let group = results[key] {
                                if !group.isEmpty {
                                    let group = group.sorted {
                                        if $0.noticeYear == $1.noticeYear {
                                            return $0.noticeWeek > $1.noticeWeek
                                        }
                                        return $0.noticeYear > $1.noticeYear
                                    }
//                                    VStack {
                                        DisclosureGroup {
                                            ForEach(group) { ntm in
                                                Divider()
                                                ntmSummary(ntm: ntm)
                                                NTMActionBar(ntm: ntm)
                                            }
                                            
                                        } label : {
                                            ntmHeader(ntm: group.first)
                                            
                                        }
//                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.all, 16)
                                    .card()
                                    .padding(.all, 8)
                                }
                            }
//                        }
                        
                    }
                    .dataSourceSummaryItem()
                }
            }
            .navigationTitle("Chart Corrections")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.backgroundColor)
            .dataSourceSummaryList()
            .onAppear(perform: loadData)
            .tint(Color.primaryColorVariant)
            if loading {
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Querying...")
                        .primary()
                }
            }
            if let queryError = queryError {
                Text("Query Error: \(queryError)")
                    .primary()
                    .padding(.all, 16)
            }
        }
    }
    
    @ViewBuilder
    func ntmHeader(ntm: ChartCorrection?) -> some View {
        if let ntm = ntm {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let internationalNumber = ntm.intlNumber {
                        Text("Chart No. \(ntm.chartNumber ?? "")")
                            .primary()
                        Text("(INT \(internationalNumber))")
                            .secondary()
                    } else {
                        Text("Chart No. \(ntm.chartNumber ?? "")")
                            .primary()
                    }
                    Spacer()
                    
                    Text("\(ntm.editionNumber ?? "") Ed. \(ntm.editionDate ?? "")")
                        .secondary()
                }
                if let currNoticeNum = ntm.currNoticeNum {
                    HStack {
                        Text("Current Notice: \(currNoticeNum)")
                            .secondary()
                        Spacer()
                        if ntm.noticeYear >= 99 || ntm.noticeYear <= Int(Calendar.current.component(.year, from: Date()) / 100) % 1000  {
                            NavigationLink {
                                NoticeToMarinersFullNoticeView(noticeNumberString: ntm.currNoticeNum)
                            } label: {
                                Text("NTM \(ntm.currNoticeNum ?? "") Details")
                            }
                            .buttonStyle(MaterialButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func correctionText(ntm: ChartCorrection) -> some View {
        if let corrections = ntm.correctionText?.correction {
            LazyVGrid(columns: columns) {
                ForEach(corrections) { result in
                    HStack(alignment: .top, spacing: 0) {
                        Text(result.action ?? "")
                        Spacer()
                    }
                    HStack(alignment: .center, spacing: 0)  {
                        Text(result.text ?? "")
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                }
                .secondary()
            }
        }
    }
    
    @ViewBuilder
    func ntmSummary(ntm: ChartCorrection) -> some View {
    
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Notice: \(ntm.currNoticeNum ?? "")")
                    .primary()
            }
            if let corrections = ntm.correctionText?.correction {
                LazyVGrid(columns: columns) {
                    ForEach(corrections, id: \.self) { result in
                        HStack(alignment: .top, spacing: 0) {
                            Text(result.action ?? "")
                            Spacer()
                        }
                        HStack(alignment: .center, spacing: 0)  {
                            Text(result.text ?? "")
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                    .secondary()
                }
            }
            Text("\(ntm.authority ?? "")")
                .secondary()
        }
    }
    
    func loadData() {
        let filters = UserDefaults.standard.filter(ChartCorrection.self)
        var queryParameters: [String] = ["output=json"]
        for filter in filters {
            if filter.property.key == "currNoticeNum", let valueInt = filter.valueInt {
                if filter.comparison == .equals {
                    queryParameters.append("noticeNumber=\(valueInt)")
                } else if filter.comparison == .lessThan {
                    let year = Int(valueInt / 100)
                    let week = Int(valueInt % 100)
                    var dateComponents = DateComponents()
                    dateComponents.year = year
                    dateComponents.weekOfYear = week
                    dateComponents.hour = 12
                    dateComponents.minute = 0
                    dateComponents.second = 0
                    dateComponents.nanosecond = 0
                    dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    let calendar = Calendar.current
                    if let date = calendar.date(from: dateComponents), let oneWeekPrior = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: date) {
                        let oneWeekAgoYear = Calendar.current.component(.year, from: oneWeekPrior)
                        let oneWeekAgoWeek = Calendar.current.component(.weekOfYear, from: oneWeekPrior)
                        queryParameters.append("maxNoticeNumber=\(oneWeekAgoYear)\(String(format: "%02d", oneWeekAgoWeek))")
                        queryParameters.append("minNoticeNumber=199929")
                    }
                } else if filter.comparison == .lessThanEqual {
                    let year = Int(valueInt / 100)
                    let week = Int(valueInt % 100)
                    var dateComponents = DateComponents()
                    dateComponents.year = year
                    dateComponents.weekOfYear = week
                    dateComponents.hour = 12
                    dateComponents.minute = 0
                    dateComponents.second = 0
                    dateComponents.nanosecond = 0
                    dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    let calendar = Calendar.current
                    if let date = calendar.date(from: dateComponents) {
                        let dateYear = Calendar.current.component(.year, from: date)
                        let dateWeek = Calendar.current.component(.weekOfYear, from: date)
                        queryParameters.append("maxNoticeNumber=\(dateYear)\(String(format: "%02d", dateWeek))")
                        queryParameters.append("minNoticeNumber=199929")
                    }
                } else if filter.comparison == .greaterThan {
                    let year = Int(valueInt / 100)
                    let week = Int(valueInt % 100)
                    var dateComponents = DateComponents()
                    dateComponents.year = year
                    dateComponents.weekOfYear = week
                    dateComponents.hour = 12
                    dateComponents.minute = 0
                    dateComponents.second = 0
                    dateComponents.nanosecond = 0
                    dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    let calendar = Calendar.current
                    if let date = calendar.date(from: dateComponents), let oneWeekForward = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: date) {
                        let oneWeekForwardYear = Calendar.current.component(.year, from: oneWeekForward)
                        let oneWeekForwardWeek = Calendar.current.component(.weekOfYear, from: oneWeekForward)
                        queryParameters.append("minNoticeNumber=\(oneWeekForwardYear)\(String(format: "%02d", oneWeekForwardWeek))")
                        let thisWeek = calendar.component(.weekOfYear, from: Date())
                        let thisYear = calendar.component(.year, from: Date())
                        queryParameters.append("maxNoticeNumber=\(thisYear)\(String(format: "%02d", thisWeek))")
                    }
                } else if filter.comparison == .greaterThanEqual {
                    let year = Int(valueInt / 100)
                    let week = Int(valueInt % 100)
                    var dateComponents = DateComponents()
                    dateComponents.year = year
                    dateComponents.weekOfYear = week
                    dateComponents.hour = 12
                    dateComponents.minute = 0
                    dateComponents.second = 0
                    dateComponents.nanosecond = 0
                    dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    let calendar = Calendar.current
                    if let date = calendar.date(from: dateComponents) {
                        let dateYear = Calendar.current.component(.year, from: date)
                        let dateWeek = Calendar.current.component(.weekOfYear, from: date)
                        queryParameters.append("minNoticeNumber=\(dateYear)\(String(format: "%02d", dateWeek))")
                        let thisWeek = calendar.component(.weekOfYear, from: Date())
                        let thisYear = calendar.component(.year, from: Date())
                        queryParameters.append("maxNoticeNumber=\(thisYear)\(String(format: "%02d", thisWeek))")
                    }
                }
            } else if filter.property.key == "location", let distance = filter.valueInt {
                var centralLongitude: Double?
                var centralLatitude: Double?
                
                if filter.comparison == .nearMe {
                    if let lastLocation = LocationManager.shared.lastLocation {
                        centralLongitude = lastLocation.coordinate.longitude
                        centralLatitude = lastLocation.coordinate.latitude
                    }
                } else if filter.comparison == .closeTo {
                    centralLongitude = filter.valueLongitude
                    centralLatitude = filter.valueLatitude
                }
                
                if let latitude = centralLatitude, let longitude = centralLongitude {
                    let nauticalMilesMeasurement = NSMeasurement(doubleValue: Double(distance), unit: UnitLength.nauticalMiles)
                    let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters)
                    let metersDistance = metersMeasurement.value
                    
                    if let metersPoint = SFGeometryUtils.degreesToMetersWith(x: longitude, andY: latitude), let x = metersPoint.x as? Double, let y = metersPoint.y as? Double {
                        let southWest = SFGeometryUtils.metersToDegreesWith(x: x - metersDistance, andY: y - metersDistance)
                        let northEast = SFGeometryUtils.metersToDegreesWith(x: x + metersDistance, andY: y + metersDistance)
                        if let southWest = southWest, let northEast = northEast, let maxy = northEast.y as? Double, let miny = southWest.y as? Double, let maxx = southWest.x as? Double, let minx = northEast.x as? Double {
                            queryParameters.append("latitudeLeft=\(miny)")
                            queryParameters.append("longitudeLeft=\(minx)")
                            queryParameters.append("latitudeRight=\(maxy)")
                            queryParameters.append("longitudeRight=\(maxx)")
                        }
                    }
                }
            }
        }
        let newUrlString = "\(MSIRouter.baseURLString)/publications/ntm/ntm-chart-corr/geo?\(queryParameters.joined(separator: "&"))"
        if newUrlString == urlString {
            return
        }
        urlString = newUrlString
        guard let url = URL(string:urlString!) else {
            self.queryError = "Invalid Chart Correction Query Parameters"
            print("Invalid Chart Correction Query Parameters")
            return
        }
        loading = true
        queryError = nil
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)

        MSI.shared.session.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: .none)
            .responseDecodable(of: ChartCorrectionPropertyContainer.self, queue: queue) { response in
                loading = false
                if let error = response.error {
                    self.queryError = error.localizedDescription
                    return
                }
                queue.async( execute:{
                    Task.detached {
                        DispatchQueue.main.async {
                            loading = false
                            self.results = Dictionary(grouping: response.value?.chartCorr ?? [], by: \.chartNumber)
                        }
                    }
                })
            }
    }
    
}

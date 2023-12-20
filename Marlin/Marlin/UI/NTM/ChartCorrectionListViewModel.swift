//
//  ChartCorrectionListViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 12/7/22.
//

import Foundation
import sf_proj_ios
import Alamofire

class ChartCorrectionListViewModel: NSObject, ObservableObject {
    @Published var queryError: String?
    @Published var loading = false
    @Published var results: [String?: [ChartCorrection]] = [:]
    
    var urlString: String?
    
    func sortedChartCorrections(key: String) -> [ChartCorrection]? {
        if let group = results[key] {
            if !group.isEmpty {
                let group = group.sorted {
                    if $0.noticeYear == $1.noticeYear {
                        return $0.noticeWeek > $1.noticeWeek
                    }
                    // let's just assume that 1950 is the first chart correction until we can figure out otherwise
                    // revisit this code in 2049
                    let zeroYear = $0.noticeYear > 50 ? $0.noticeYear + 1900 : $0.noticeYear + 2000
                    let oneYear = $1.noticeYear > 50 ? $1.noticeYear + 1900 : $1.noticeYear + 2000
                    return zeroYear > oneYear
                }
                return group
            }
        }
        return nil
    }
    
    var sortedChartIds: [String] {
        return results.keys.sorted {
            return Int($0 ?? "-1") ?? -1 < Int($1 ?? "-1") ?? -1
        }.compactMap { $0 }
    }

    func lessThan(value: Int, queryParameters: inout [String]) {
        let year = Int(value / 100)
        let week = Int(value % 100)
        var dateComponents = DateComponents()
        dateComponents.yearForWeekOfYear = year
        dateComponents.weekOfYear = week
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)

        let calendar = Calendar.current
        if let date = calendar.date(from: dateComponents),
            let oneWeekPrior = Calendar.current.date(
                byAdding: .weekOfYear,
                value: -1,
                to: date) {
            let oneWeekAgoYear = Calendar.current.component(.yearForWeekOfYear, from: oneWeekPrior)
            let oneWeekAgoWeek = Calendar.current.component(.weekOfYear, from: oneWeekPrior)
            queryParameters.append(
                "maxNoticeNumber=\(oneWeekAgoYear)\(String(format: "%02d", oneWeekAgoWeek))")
            queryParameters.append("minNoticeNumber=199929")
        }
    }

    func greaterThan(value: Int, queryParameters: inout [String]) {
        let year = Int(value / 100)
        let week = Int(value % 100)
        var dateComponents = DateComponents()
        dateComponents.weekOfYear = week
        dateComponents.yearForWeekOfYear = year
        dateComponents.hour = 12
        dateComponents.minute = 0
        dateComponents.second = 0
        dateComponents.nanosecond = 0
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)

        let calendar = Calendar.current
        if let date = calendar.date(from: dateComponents),
            let oneWeekForward = Calendar.current.date(
                byAdding: .weekOfYear,
                value: 1,
                to: date) {
            let oneWeekForwardYear = Calendar.current.component(.yearForWeekOfYear, from: oneWeekForward)
            let oneWeekForwardWeek = Calendar.current.component(.weekOfYear, from: oneWeekForward)
            queryParameters.append(
                "minNoticeNumber=\(oneWeekForwardYear)\(String(format: "%02d", oneWeekForwardWeek))")
            let thisWeek = calendar.component(.weekOfYear, from: Date())
            let thisYear = calendar.component(.yearForWeekOfYear, from: Date())
            queryParameters.append("maxNoticeNumber=\(thisYear)\(String(format: "%02d", thisWeek))")
        }
    }

    func locationParameters(filter: DataSourceFilterParameter, queryParameters: inout [String]) -> Bool {
        var validQuery = false
        var centralLongitude: Double?
        var centralLatitude: Double?

        if filter.comparison == .nearMe {
            if let lastLocation = LocationManager.shared().lastLocation {
                centralLongitude = lastLocation.coordinate.longitude
                centralLatitude = lastLocation.coordinate.latitude
            }
        } else if filter.comparison == .closeTo {
            centralLongitude = filter.valueLongitude
            centralLatitude = filter.valueLatitude
        }

        if let latitude = centralLatitude, let longitude = centralLongitude, let distance = filter.valueInt {
            let nauticalMilesMeasurement =
            NSMeasurement(doubleValue: Double(distance), unit: UnitLength.nauticalMiles)
            let metersMeasurement = nauticalMilesMeasurement.converting(to: UnitLength.meters)
            let metersDistance = metersMeasurement.value

            if let metersPoint = SFGeometryUtils.degreesToMetersWith(
                x: longitude,
                andY: latitude),
               let xPoint = metersPoint.x as? Double,
               let yPoint = metersPoint.y as? Double {
                let southWest = SFGeometryUtils.metersToDegreesWith(
                    x: xPoint - metersDistance,
                    andY: yPoint - metersDistance)
                let northEast = SFGeometryUtils.metersToDegreesWith(
                    x: xPoint + metersDistance,
                    andY: yPoint + metersDistance)
                if let southWest = southWest,
                    let northEast = northEast,
                   let maxy = northEast.y as? Double,
                   let miny = southWest.y as? Double,
                   let maxx = northEast.x as? Double,
                   let minx = southWest.x as? Double {
                    validQuery = true
                    queryParameters.append("latitudeLeft=\(miny)")
                    queryParameters.append("longitudeLeft=\(minx)")
                    queryParameters.append("latitudeRight=\(maxy)")
                    queryParameters.append("longitudeRight=\(maxx)")
                }
            }
        }
        return validQuery
    }

    func createQueryParameters() -> [String]? {
        var validQuery = false
        let filters = UserDefaults.standard.filter(ChartCorrection.definition)
        var queryParameters: [String] = ["output=json"]
        for filter in filters {
            if filter.property.key == "currNoticeNum", let valueInt = filter.valueInt {
                if filter.comparison == .equals {
                    queryParameters.append("noticeNumber=\(valueInt)")
                } else if filter.comparison == .lessThan {
                    lessThan(value: valueInt, queryParameters: &queryParameters)
                } else if filter.comparison == .lessThanEqual {
                    queryParameters.append("maxNoticeNumber=\(valueInt)")
                    queryParameters.append("minNoticeNumber=199929")
                } else if filter.comparison == .greaterThan {
                    greaterThan(value: valueInt, queryParameters: &queryParameters)
                } else if filter.comparison == .greaterThanEqual {
                    let calendar = Calendar.current
                    queryParameters.append("minNoticeNumber=\(valueInt)")
                    let thisWeek = calendar.component(.weekOfYear, from: Date())
                    let thisYear = calendar.component(.yearForWeekOfYear, from: Date())
                    queryParameters.append("maxNoticeNumber=\(thisYear)\(String(format: "%02d", thisWeek))")
                }
            } else if filter.property.key == "location" {
                validQuery = locationParameters(filter: filter, queryParameters: &queryParameters)
            }
        }
        if validQuery {
            return queryParameters
        }
        return nil
    }
    
    func loadData() {
        guard let queryParameters = createQueryParameters() else {
            self.queryError = "Invalid Chart Correction Query Parameters"
            print("Invalid Chart Correction Query Parameters")
            return
        }

        let newUrlString = """
            \(MSIRouter.baseURLString)/publications/ntm/ntm-chart-corr/geo?\
            \(queryParameters.joined(separator: "&"))
        """
        if newUrlString == urlString {
            return
        }
        urlString = newUrlString
        guard let url = URL(string: urlString!) else {
            self.queryError = "Invalid Chart Correction Query Parameters"
            print("Invalid Chart Correction Query Parameters")
            return
        }
        loading = true
        queryError = nil
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        
        MSI.shared.session.request(url, 
                                   method: .get,
                                   parameters: nil,
                                   encoding: URLEncoding.default,
                                   headers: nil,
                                   interceptor: nil,
                                   requestModifier: .none)
            .responseDecodable(of: ChartCorrectionPropertyContainer.self, queue: queue) { response in
                queue.async(execute: {
                    Task.detached {
                        DispatchQueue.main.async {
                            self.loading = false
                            if let error = response.error {
                                self.queryError = error.localizedDescription
                                return
                            }
                            self.results = Dictionary(grouping: response.value?.chartCorr ?? [], by: \.chartNumber)
                        }
                    }
                })
            }
    }
}

//
//  SortPreferences.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation

extension UserDefaults {

    func sortPublisher(key: String) -> NSObject.KeyValueObservingPublisher<UserDefaults, Data?> {
        switch key {
        case DataSources.asam.key:
            return publisher(for: \.asamSort)
        case DataSources.modu.key:
            return publisher(for: \.moduSort)
        case Light.key:
            return publisher(for: \.lightSort)
        case NoticeToMariners.key:
            return publisher(for: \.ntmSort)
        case DFRS.key:
            return publisher(for: \.dfrsSort)
        case DifferentialGPSStation.key:
            return publisher(for: \.differentialGPSStationSort)
        case ElectronicPublication.key:
            return publisher(for: \.epubSort)
        case DataSources.port.key:
            return publisher(for: \.portSort)
        case DataSources.radioBeacon.key:
            return publisher(for: \.radioBeaconSort)
        default:
            return publisher(for: \.asamSort)
        }
    }

    @objc var asamSort: Data? {
        data(forKey: #function)
    }

    @objc var moduSort: Data? {
        data(forKey: #function)
    }

    @objc var portSort: Data? {
        data(forKey: #function)
    }

    @objc var radioBeaconSort: Data? {
        data(forKey: #function)
    }

    @objc var differentialGPSStationSort: Data? {
        data(forKey: #function)
    }

    @objc var dfrsSort: Data? {
        data(forKey: #function)
    }

    @objc var ntmSort: Data? {
        data(forKey: #function)
    }

    @objc var lightSort: Data? {
        data(forKey: #function)
    }

    @objc var epubSort: Data? {
        data(forKey: #function)
    }

    func sort(_ key: String) -> [DataSourceSortParameter] {
        if let data = data(forKey: "\(key)Sort") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let sort = try decoder.decode([DataSourceSortParameter].self, from: data)

                return sort
            } catch {
                print("Unable to Decode sort (\(error))")
            }
        }
        return []
    }

    func setSort(_ key: String, sort: [DataSourceSortParameter]) {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let data = try encoder.encode(sort)

            // Write/Set Data
            UserDefaults.standard.set(data, forKey: "\(key)Sort")
            NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceUpdatedNotification(key: key))
        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
    }
}

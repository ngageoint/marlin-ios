//
//  FilterPreferences.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation

extension UserDefaults {
    func filterPublisher(key: String) -> NSObject.KeyValueObservingPublisher<UserDefaults, Data?> {
        switch key {
        case DataSources.asam.key:
            return publisher(for: \.asamFilter)
        case DataSources.modu.key:
            return publisher(for: \.moduFilter)
        case DataSources.light.key:
            return publisher(for: \.lightFilter)
        case DataSources.noticeToMariners.key:
            return publisher(for: \.ntmFilter)
        case DataSources.dgps.key:
            return publisher(for: \.differentialGPSStationFilter)
        case DataSources.epub.key:
            return publisher(for: \.epubFilter)
        case DataSources.port.key:
            return publisher(for: \.portFilter)
        case DataSources.radioBeacon.key:
            return publisher(for: \.radioBeaconFilter)
        default:
            return publisher(for: \.asamFilter)
        }
    }

    @objc var asamFilter: Data? {
        data(forKey: #function)
    }

    @objc var moduFilter: Data? {
        data(forKey: #function)
    }

    @objc var portFilter: Data? {
        data(forKey: #function)
    }

    @objc var radioBeaconFilter: Data? {
        data(forKey: #function)
    }

    @objc var differentialGPSStationFilter: Data? {
        data(forKey: #function)
    }
    @objc var dfrsFilter: Data? {
        data(forKey: #function)
    }

    @objc var lightFilter: Data? {
        data(forKey: #function)
    }

    @objc var epubFilter: Data? {
        data(forKey: #function)
    }

    @objc var ntmFilter: Data? {
        data(forKey: #function)
    }

    func filter(_ dataSource: any DataSourceDefinition) -> [DataSourceFilterParameter] {
        if let data = data(forKey: "\(dataSource.key)Filter") {
            do {
                // Create JSON Decoder
                let decoder = JSONDecoder()

                // Decode Note
                let filter = try decoder.decode([DataSourceFilterParameter].self, from: data)

                return filter
            } catch {
                print("Unable to Decode Notes (\(error))")
            }
        }
        return []
    }

    func setFilter(_ key: String, filter: [DataSourceFilterParameter]) {
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let data = try encoder.encode(filter)

            // Write/Set Data
            UserDefaults.standard.set(data, forKey: "\(key)Filter")
            NotificationCenter.default.post(name: .DataSourceUpdated, object: DataSourceUpdatedNotification(key: key))
        } catch {
            print("Unable to Encode Array of Notes (\(error))")
        }
    }
}

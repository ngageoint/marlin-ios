//
//  DataSourcePreferences.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation

extension UserDefaults {
    func orderPublisher(key: String) -> NSObject.KeyValueObservingPublisher<UserDefaults, Int> {
        switch key {
        case DataSources.asam.key:
            return publisher(for: \.asamOrder)
        case DataSources.modu.key:
            return publisher(for: \.moduOrder)
        case DataSources.light.key:
            return publisher(for: \.lightOrder)
        case NoticeToMariners.key:
            return publisher(for: \.ntmOrder)
        case DFRS.key:
            return publisher(for: \.dfrsOrder)
        case DataSources.dgps.key:
            return publisher(for: \.differentialGPSStationOrder)
        case ElectronicPublication.key:
            return publisher(for: \.epubOrder)
        case DataSources.port.key:
            return publisher(for: \.portOrder)
        case DataSources.radioBeacon.key:
            return publisher(for: \.radioBeaconOrder)
        case NavigationalWarning.key:
            return publisher(for: \.navWarningOrder)
        default:
            return publisher(for: \.asamOrder)
        }
    }

    @objc var asamOrder: Int {
        integer(forKey: #function)
    }

    @objc var moduOrder: Int {
        integer(forKey: #function)
    }

    @objc var portOrder: Int {
        integer(forKey: #function)
    }

    @objc var radioBeaconOrder: Int {
        integer(forKey: #function)
    }

    @objc var differentialGPSStationOrder: Int {
        integer(forKey: #function)
    }
    @objc var dfrsOrder: Int {
        integer(forKey: #function)
    }

    @objc var lightOrder: Int {
        integer(forKey: #function)
    }

    @objc var epubOrder: Int {
        integer(forKey: #function)
    }

    @objc var ntmOrder: Int {
        integer(forKey: #function)
    }

    @objc var navWarningOrder: Int {
        integer(forKey: #function)
    }

    func lastSyncTimeSeconds(_ dataSource: any DataSourceDefinition) -> Double {
        return double(forKey: "\(dataSource.key)LastSyncTime")
    }

    func updateLastSyncTimeSeconds(_ dataSource: any DataSourceDefinition) {
        setValue(Date().timeIntervalSince1970, forKey: "\(dataSource.key)LastSyncTime")
    }

    func clearLastSyncTimeSeconds(_ dataSource: any DataSourceDefinition) {
        removeObject(forKey: "\(dataSource.key)LastSyncTime")
    }

    var navigationalWarningsLocationsParsed: Bool {
        get {
            return bool(forKey: #function)
        }
        set {
            setValue(newValue, forKey: #function)
        }
    }
}

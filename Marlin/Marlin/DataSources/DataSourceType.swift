//
//  DataSourceType.swift
//  Marlin
//
//  Created by Daniel Barela on 12/20/23.
//

import Foundation

// TODO: this should go away
enum DataSourceType: String, CaseIterable {
    case asam
    case modu
    case light
    case port
    case differentialGPSStation
    case radioBeacon
    // swiftlint:disable identifier_name
    case Common
    // swiftlint:enable identifier_name
    case route
    case ntm
    case epub
    case navWarning

    static func fromKey(_ key: String) -> DataSourceType? {
        return self.allCases.first { "\($0)" == key }
    }

    // this cannot be fixed since we have this many data sources
    // swiftlint:disable cyclomatic_complexity
    func toDataSource() -> DataSource.Type {
        switch self {
        case .asam:
            return AsamModel.self
        case .modu:
            return Modu.self
        case .light:
            return Light.self
        case .port:
            return Port.self
        case .differentialGPSStation:
            return DifferentialGPSStation.self
        case .radioBeacon:
            return RadioBeacon.self
        case .Common:
            return CommonDataSource.self
        case .route:
            return Route.self
        case .ntm:
            return NoticeToMariners.self
        case .epub:
            return ElectronicPublication.self
        case .navWarning:
            return NavigationalWarning.self
        }
    }
    // swiftlint:enable cyclomatic_complexity

    func asamModel(dataSource: DataSource?) -> DataSource? {
        if let asam = dataSource as? Asam {
            return AsamModel(asam: asam)
        }
        return nil
    }

    func moduModel(dataSource: DataSource?) -> DataSource? {
        if let modu = dataSource as? Modu {
            return ModuModel(modu: modu)
        }
        return nil
    }
    func lightModel(dataSource: DataSource?) -> DataSource? {
        if let light = dataSource as? Light {
            return LightModel(light: light)
        }
        return nil
    }
    func portModel(dataSource: DataSource?) -> DataSource? {
        if let port = dataSource as? Port {
            return PortModel(port: port)
        }
        return nil
    }
    func differentialGPSStationModel(dataSource: DataSource?) -> DataSource? {
        if let differentialGPSStation = dataSource as? DifferentialGPSStation {
            return DifferentialGPSStationModel(differentialGPSStation: differentialGPSStation)
        }
        return nil
    }
    func radioBeaconModel(dataSource: DataSource?) -> DataSource? {
        if let radioBeacon = dataSource as? RadioBeacon {
            return RadioBeaconModel(radioBeacon: radioBeacon)
        }
        return nil
    }
    func commonModel(dataSource: DataSource?) -> DataSource? {
        if let common = dataSource as? CommonDataSource {
            return common
        }
        return nil
    }
    func routeModel(dataSource: DataSource?) -> DataSource? {
        if let route = dataSource as? Route {
            return route
        }
        return nil
    }
    func ntmModel(dataSource: DataSource?) -> DataSource? {
        if let ntm = dataSource as? NoticeToMariners {
            return ntm
        }
        return nil
    }
    func epubModel(dataSource: DataSource?) -> DataSource? {
        if let epub = dataSource as? ElectronicPublication {
            return epub
        }
        return nil
    }
    func navWarningModel(dataSource: DataSource?) -> DataSource? {
        if let navWarning = dataSource as? NavigationalWarning {
            return navWarning
        }
        return nil
    }

    // this cannot be fixed since we have this many data sources
    // swiftlint:disable cyclomatic_complexity
    func createModel(dataSource: DataSource?) -> DataSource? {
        switch self {
        case .asam:
            return asamModel(dataSource: dataSource)
        case .modu:
            return moduModel(dataSource: dataSource)
        case .light:
            return lightModel(dataSource: dataSource)
        case .port:
            return portModel(dataSource: dataSource)
        case .differentialGPSStation:
            return differentialGPSStationModel(dataSource: dataSource)
        case .radioBeacon:
            return radioBeaconModel(dataSource: dataSource)
        case .Common:
            return commonModel(dataSource: dataSource)
        case .route:
            return routeModel(dataSource: dataSource)
        case .ntm:
            return ntmModel(dataSource: dataSource)
        case .epub:
            return epubModel(dataSource: dataSource)
        case .navWarning:
            return navWarningModel(dataSource: dataSource)
        }
    }
    // swiftlint:enable cyclomatic_complexity
}

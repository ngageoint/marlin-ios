//
//  LightGeoPackageExportable.swift
//  Marlin
//
//  Created by Daniel Barela on 2/9/24.
//

import Foundation
import geopackage_ios
import ExceptionCatcher
import sf_ios

class LightGeoPackageExportable: GeoPackageExportable {
    static var definition: any DataSourceDefinition = DataSources.light

    let lightRepository: LightRepository
    init(lightRepository: LightRepository) {
        self.lightRepository = lightRepository
    }

    func createFeatures(
        geoPackage: GPKGGeoPackage,
        table: GPKGFeatureTable,
        filters: [DataSourceFilterParameter]?,
        styleRows: [GPKGStyleRow],
        dataSourceProgress: DataSourceExportProgress
    ) async throws {

        let models = await lightRepository.getLights(filters: (filters ?? []))
        var exported = 0
        for model in models {
            for (color, sfGeometry) in model.sfGeometryByColor() ?? [:] {
                var styleArray: [GPKGStyleRow] = []
                if color == Light.redLight {
                    styleArray.append(styleRows[0])
                } else if color == Light.greenLight {
                    styleArray.append(styleRows[1])
                } else if color == Light.blueLight {
                    styleArray.append(styleRows[2])
                } else if color == Light.whiteLight {
                    styleArray.append(styleRows[3])
                } else if color == Light.yellowLight {
                    styleArray.append(styleRows[4])
                } else if color == Light.violetLight {
                    styleArray.append(styleRows[5])
                } else if color == Light.orangeLight {
                    styleArray.append(styleRows[6])
                }

                createFeature(
                    model: model,
                    sfGeometry: sfGeometry,
                    geoPackage: geoPackage,
                    table: table,
                    styleRows: styleArray
                )
            }
            exported += 1
            if exported % 10 == 0 {
                await updateProgress(dataSourceProgress: dataSourceProgress, count: exported)
            }
        }
        await updateProgress(dataSourceProgress: dataSourceProgress, count: exported)
    }

    func createFeature(
        model: Encodable,
        sfGeometry: SFGeometry?,
        geoPackage: GPKGGeoPackage,
        table: GPKGFeatureTable,
        styleRows: [GPKGStyleRow]
    ) {
        guard let featureDao = geoPackage.featureDao(with: table),
              let featureTableStyles = GPKGFeatureTableStyles(geoPackage: geoPackage, andTable: table),
              let row = featureDao.newRow() else {
            return
        }

        if let sfGeometry = sfGeometry {
            let gpkgGeometry = GPKGGeometryData(geometry: sfGeometry)
            row.setValueWithColumnName("geometry", andValue: gpkgGeometry)
        }
        let dictionary = model.dictionary ?? [:]
        let propertiesByName = Dictionary(grouping: Self.definition.filterable?.properties ?? [], by: \.key)
        for (_, properties) in propertiesByName {
            if let property = properties.filter({ property in
                property.subEntityKey == nil
            }).first {
                if let value = dictionary[property.key] as? NSObject {
                    row.setValueWithColumnName(property.key, andValue: value)
                }
            }
        }
        do {
            try ExceptionCatcher.catch {
                let rowId = featureDao.create(row)
                if !styleRows.isEmpty {
                    featureTableStyles.setStyleDefault(styleRows[0], withId: Int32(rowId))
                }
            }
        } catch {
            print("Excetion creating feature \(error.localizedDescription)")
        }
    }

    func createStyles(tableStyles: GPKGFeatureTableStyles) -> [GPKGStyleRow] {
        var styleRows: [GPKGStyleRow] = []

        if let red = redStyleRow(tableStyles: tableStyles) {
            styleRows.append(red)
        }
        if let green = greenStyleRow(tableStyles: tableStyles) {
            styleRows.append(green)
        }
        if let blue = blueStyleRow(tableStyles: tableStyles) {
            styleRows.append(blue)
        }

        if let white = whiteStyleRow(tableStyles: tableStyles) {
            styleRows.append(white)
        }

        if let yellow = yellowStyleRow(tableStyles: tableStyles) {
            styleRows.append(yellow)
        }

        if let violet = violetStyleRow(tableStyles: tableStyles) {
            styleRows.append(violet)
        }

        if let orange = orangeStyleRow(tableStyles: tableStyles) {
            styleRows.append(orange)
        }

        return styleRows
    }

    func redStyleRow(tableStyles: GPKGFeatureTableStyles) -> GPKGStyleRow? {
        let red = tableStyles.styleDao().newRow()
        red?.setName("RedLightStyle")
        red?.setColor(CLRColor(
            red: Int32(Light.redLight.redComponent * 255.0),
            andGreen: Int32(Light.redLight.greenComponent * 255.0),
            andBlue: Int32(Light.redLight.blueComponent * 255.0)))
        red?.setFillColor(CLRColor(
            red: Int32(Light.redLight.redComponent * 255.0),
            andGreen: Int32(Light.redLight.greenComponent * 255.0),
            andBlue: Int32(Light.redLight.blueComponent * 255.0)))
        red?.setFillOpacity(0.3)
        red?.setWidth(2.0)
        return red
    }

    func greenStyleRow(tableStyles: GPKGFeatureTableStyles) -> GPKGStyleRow? {
        let green = tableStyles.styleDao().newRow()
        green?.setName("GreenLightStyle")
        green?.setColor(CLRColor(
            red: Int32(Light.greenLight.redComponent * 255.0),
            andGreen: Int32(Light.greenLight.greenComponent * 255.0),
            andBlue: Int32(Light.greenLight.blueComponent * 255.0)))
        green?.setFillColor(CLRColor(
            red: Int32(Light.greenLight.redComponent * 255.0),
            andGreen: Int32(Light.greenLight.greenComponent * 255.0),
            andBlue: Int32(Light.greenLight.blueComponent * 255.0)))
        green?.setFillOpacity(0.3)
        green?.setWidth(2.0)
        return green
    }

    func blueStyleRow(tableStyles: GPKGFeatureTableStyles) -> GPKGStyleRow? {
        let blue = tableStyles.styleDao().newRow()
        blue?.setName("BlueLightStyle")
        blue?.setColor(CLRColor(
            red: Int32(Light.blueLight.redComponent * 255.0),
            andGreen: Int32(Light.blueLight.greenComponent * 255.0),
            andBlue: Int32(Light.blueLight.blueComponent * 255.0)))
        blue?.setFillColor(
            CLRColor(red: Int32(Light.blueLight.redComponent * 255.0),
                     andGreen: Int32(Light.blueLight.greenComponent * 255.0),
                     andBlue: Int32(Light.blueLight.blueComponent * 255.0)))
        blue?.setFillOpacity(0.3)
        blue?.setWidth(2.0)
        return blue
    }

    func whiteStyleRow(tableStyles: GPKGFeatureTableStyles) -> GPKGStyleRow? {
        let white = tableStyles.styleDao().newRow()
        white?.setName("WhiteLightStyle")
        white?.setColor(CLRColor(
            red: Int32(Light.whiteLight.redComponent * 255.0),
            andGreen: Int32(Light.whiteLight.greenComponent * 255.0),
            andBlue: Int32(Light.whiteLight.blueComponent * 255.0)))
        white?.setFillColor(CLRColor(
            red: Int32(Light.whiteLight.redComponent * 255.0),
            andGreen: Int32(Light.whiteLight.greenComponent * 255.0),
            andBlue: Int32(Light.whiteLight.blueComponent * 255.0)))
        white?.setFillOpacity(0.3)
        white?.setWidth(2.0)
        return white
    }

    func yellowStyleRow(tableStyles: GPKGFeatureTableStyles) -> GPKGStyleRow? {
        let yellow = tableStyles.styleDao().newRow()
        yellow?.setName("YellowLightStyle")
        yellow?.setColor(CLRColor(
            red: Int32(Light.yellowLight.redComponent * 255.0),
            andGreen: Int32(Light.yellowLight.greenComponent * 255.0),
            andBlue: Int32(Light.yellowLight.blueComponent * 255.0)))
        yellow?.setFillColor(CLRColor(
            red: Int32(Light.yellowLight.redComponent * 255.0),
            andGreen: Int32(Light.yellowLight.greenComponent * 255.0),
            andBlue: Int32(Light.yellowLight.blueComponent * 255.0)))
        yellow?.setFillOpacity(0.3)
        yellow?.setWidth(2.0)
        return yellow
    }

    func violetStyleRow(tableStyles: GPKGFeatureTableStyles) -> GPKGStyleRow? {
        let violet = tableStyles.styleDao().newRow()
        violet?.setName("VioletLightStyle")
        violet?.setColor(CLRColor(
            red: Int32(Light.violetLight.redComponent * 255.0),
            andGreen: Int32(Light.violetLight.greenComponent * 255.0),
            andBlue: Int32(Light.violetLight.blueComponent * 255.0)))
        violet?.setFillColor(CLRColor(
            red: Int32(Light.violetLight.redComponent * 255.0),
            andGreen: Int32(Light.violetLight.greenComponent * 255.0),
            andBlue: Int32(Light.violetLight.blueComponent * 255.0)))
        violet?.setFillOpacity(0.3)
        violet?.setWidth(2.0)
        return violet
    }

    func orangeStyleRow(tableStyles: GPKGFeatureTableStyles) -> GPKGStyleRow? {
        let orange = tableStyles.styleDao().newRow()
        orange?.setName("OrangeLightStyle")
        orange?.setColor(CLRColor(
            red: Int32(Light.orangeLight.redComponent * 255.0),
            andGreen: Int32(Light.orangeLight.greenComponent * 255.0),
            andBlue: Int32(Light.orangeLight.blueComponent * 255.0)))
        orange?.setFillColor(CLRColor(
            red: Int32(Light.orangeLight.redComponent * 255.0),
            andGreen: Int32(Light.orangeLight.greenComponent * 255.0),
            andBlue: Int32(Light.orangeLight.blueComponent * 255.0)))
        orange?.setFillOpacity(0.3)
        orange?.setWidth(2.0)
        return orange
    }

    @MainActor
    func updateProgress(dataSourceProgress: DataSourceExportProgress, count: Int) {
        dataSourceProgress.exportCount = Float(count)
    }
}

//
//  BaseMapOverlay.swift
//  Marlin
//
//  Created by Daniel Barela on 6/29/22.
//

import Foundation
import UIKit
import geopackage_ios

class BaseMapOverlay: GPKGFeatureOverlay, OverlayRenderable {
    var renderer: MKOverlayRenderer {
        get {
            return MKTileOverlayRenderer(overlay: self)
        }
    }
    @objc public var fillColor: UIColor = UIColor.clear
    
    @objc public func cleanup() {
        featureTiles = nil
    }
    
    init(featureTiles: GPKGFeatureTiles!, fillColor: UIColor? = nil) {
        super.init(featureTiles: featureTiles)
        if let fillColor = fillColor {
            self.fillColor = fillColor
        }
    }
    
    override func retrieveTileWith(x: Int, andY y: Int, andZoom zoom: Int) -> Data! {
        let tileWidth = self.tileSize.width
        let tileHeight = self.tileSize.height

        UIGraphicsBeginImageContext(CGSize(width: tileWidth, height: tileHeight))
        let context = UIGraphicsGetCurrentContext()

        // Create the tile path
        let tilePath = CGMutablePath()
        tilePath.move(to: CGPoint(x: 0, y: 0))
        tilePath.addLine(to: CGPoint(x: 0, y: tileHeight))
        tilePath.addLine(to: CGPoint(x: tileWidth, y: tileHeight))
        tilePath.addLine(to: CGPoint(x: tileWidth, y: 0))
        tilePath.addLine(to: CGPoint(x: 0, y: 0))
        tilePath.closeSubpath()

        context?.setFillColor(fillColor.cgColor)
        context?.addPath(tilePath)
        context?.drawPath(using: .fill)
        let featureImage = self.featureTiles.drawTileWith(x: Int32(x), andY: Int32(y), andZoom: Int32(zoom))
        featureImage?.draw(in: CGRect(x: 0, y: 0, width: tileWidth, height: tileHeight))

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return GPKGImageConverter.toData(image, andFormat: GPKGCompressFormats.fromName(GPKG_CF_PNG_NAME))
    }
}

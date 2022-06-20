//
//  MarlinMapView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import UIKit
import PureLayout
import MaterialComponents
import MapKit

protocol OverlayRenderable {
    var renderer: MKOverlayRenderer { get }
}

class MarlinMapView: UIView, AsamMap, ModuMap, BottomSheetEnabled {
    var navigationController: UINavigationController?
    
    func addFilteredAsams() {
        
    }
    
    func addFilteredModus() {
        
    }
    
    var mapView: MKMapView?
    var scheme: MarlinScheme?;
    var mapMixins: [MapMixin] = []
    var asamMapMixin: AsamMapMixin?
    var moduMapMixin: ModuMapMixin?
    var bottomSheetMixin: BottomSheetMixin?

    
    lazy var mapStack: UIStackView = {
        let mapStack = UIStackView.newAutoLayout()
        mapStack.axis = .vertical
        mapStack.alignment = .fill
        mapStack.spacing = 0
        mapStack.distribution = .fill
        return mapStack
    }()
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    public init(scheme: MarlinScheme?) {
        super.init(frame: .zero)
        self.scheme = scheme
        layoutView()
    }
    
    func layoutView() {
        mapView = MKMapView.newAutoLayout()
        guard let mapView = mapView else {
            return
        }
        
        self.addSubview(mapView)
        mapView.autoPinEdgesToSuperviewEdges()
        mapView.delegate = self
        
        self.addSubview(mapStack)
        if UIDevice.current.userInterfaceIdiom == .pad {
            mapStack.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        } else {
            mapStack.autoPinEdgesToSuperviewSafeArea(with: .zero, excludingEdge: .top)
        }
        
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(singleTapGensture(tapGestureRecognizer:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.delaysTouchesBegan = true
        singleTapGestureRecognizer.cancelsTouchesInView = true
        singleTapGestureRecognizer.delegate = self
        self.mapView?.addGestureRecognizer(singleTapGestureRecognizer)
        asamMapMixin = AsamMapMixin(asamMap: self, scheme: scheme)
        mapMixins.append(asamMapMixin!)
        moduMapMixin = ModuMapMixin(moduMap: self, scheme: scheme)
        mapMixins.append(moduMapMixin!)
        bottomSheetMixin = BottomSheetMixin(bottomSheetEnabled: self)
        mapMixins.append(bottomSheetMixin!)
        initiateMapMixins()
        

    }
    
    func initiateMapMixins() {
        for mixin in mapMixins {
            mixin.setupMixin()
            mixin.applyTheme(scheme: scheme)
        }
    }
    
    func cleanupMapMixins() {
        for mixin in mapMixins {
            mixin.cleanupMixin()
        }
        mapMixins.removeAll()
    }
    
    func applyTheme(scheme: MarlinScheme?) {
        self.scheme = scheme
        for mixin in mapMixins {
            mixin.applyTheme(scheme: scheme)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        for mixin in mapMixins {
            mixin.traitCollectionUpdated(previous: previousTraitCollection)
        }
    }
    
    @objc func singleTapGensture(tapGestureRecognizer: UITapGestureRecognizer) {
        if tapGestureRecognizer.state == .ended {
            mapTap(tapPoint: tapGestureRecognizer.location(in: mapView), gesture: tapGestureRecognizer)
        }
    }
    
    func mapTap(tapPoint:CGPoint, gesture: UITapGestureRecognizer) {
        guard let mapView = mapView else {
            return
        }
        
        let tapCoord = mapView.convert(tapPoint, toCoordinateFrom: mapView)
        var annotationsTapped: [Any] = []
        let visibleMapRect = mapView.visibleMapRect
        let annotationsVisible = mapView.annotations(in: visibleMapRect)
        
        for annotation in annotationsVisible {
            if let mkAnnotation = annotation as? MKAnnotation, let view = mapView.view(for: mkAnnotation) {
                let location = gesture.location(in: view)
                if view.bounds.contains(location) {
                    annotationsTapped.append(annotation)
                }
            }
        }
        
        var items: [Any] = []
        for mixin in mapMixins {
            if let matchedItems = mixin.items(at: tapCoord) {
                items.append(contentsOf: matchedItems)
            }
        }
        
        print("sending notification for annotations \(annotationsTapped.count)")
        let notification = MapItemsTappedNotification(annotations: annotationsTapped, items: items, mapView: mapView)
        NotificationCenter.default.post(name: .MapItemsTapped, object: notification)
    }
}

extension MarlinMapView : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let renderableOverlay = overlay as? OverlayRenderable {
            return renderableOverlay.renderer
        }
        for mixin in mapMixins {
            if let renderer = mixin.renderer(overlay: overlay) {
                return renderer
            }
        }
        return MKTileOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        for mixin in mapMixins {
            if let view = mixin.viewForAnnotation(annotation: annotation, mapView: mapView){
                return view
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        for mixin in mapMixins {
            mixin.regionDidChange(mapView: mapView, animated: animated)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        for mixin in mapMixins {
            mixin.regionWillChange(mapView: mapView, animated: animated)
        }
    }
    
    func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
        for mixin in mapMixins {
            mixin.didChangeUserTrackingMode(mapView: mapView, animated: animated)
        }
    }
}

extension MarlinMapView : UIGestureRecognizerDelegate {
    
}

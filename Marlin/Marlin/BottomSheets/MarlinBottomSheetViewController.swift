//
//  MarlinBottomSheetViewController.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import UIKit
import MapKit
import MaterialComponents
import SwiftUI
import PureLayout

class PassThroughStackView : UIStackView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result == self { return nil }
        return result
    }
}

class BottomSheetItem: NSObject {
    var item: Any
    var annotationView: MKAnnotationView?
    var actionDelegate: Any?
    
    init(item: Any, actionDelegate: Any? = nil, annotationView: MKAnnotationView? = nil) {
        self.item = item;
        self.actionDelegate = actionDelegate;
        self.annotationView = annotationView;
    }
}

class MarlinBottomSheetViewController: UIViewController {
    
    private var didSetUpConstraints = false;
    private var items: [BottomSheetItem] = [];
    var scheme: MarlinScheme?;
    private var rightConstraint: NSLayoutConstraint?;
    private var leftConstraint: NSLayoutConstraint?;
    var currentAsamBottomSheetView: UIHostingController<AsamBottomSheet>?
    var currentModuBottomSheetView: UIHostingController<ModuBottomSheet>?
    var currentLightBottomSheetView: UIHostingController<LightBottomSheet>?
    var mapView: MKMapView?
        
    @objc public lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView.newAutoLayout();
        scrollView.accessibilityIdentifier = "feature bottom sheet";
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return scrollView;
    }()
    
    private lazy var stackView: PassThroughStackView = {
        let stackView = PassThroughStackView(forAutoLayout: ());
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.distribution = .fill;
        stackView.directionalLayoutMargins = .zero;
        stackView.isLayoutMarginsRelativeArrangement = false;
        stackView.translatesAutoresizingMaskIntoConstraints = false;
        stackView.clipsToBounds = true;
        return stackView;
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl();
        pageControl.currentPage = 0;
        pageControl.hidesForSinglePage = true;
        pageControl.addTarget(self, action: #selector(pageControlChangedValue), for: .valueChanged)
        return pageControl;
    }()
    
    private lazy var pageNumberLabel: UILabel = {
        let pageNumberLabel = UILabel();
        pageNumberLabel.textAlignment = .center;
        return pageNumberLabel;
    }()
    
    private lazy var pageControlHolder: UIView = {
        let view = UIView(forAutoLayout: ());
        view.addSubview(pageNumberLabel);
        view.addSubview(leftButton);
        view.addSubview(pageControl);
        view.addSubview(rightButton);
        
        leftButton.autoPinEdge(.right, to: .left, of: pageControl);
        leftButton.autoPinEdge(toSuperviewEdge: .bottom);
        leftButton.autoPinEdge(toSuperviewEdge: .top, withInset: 7);
        pageControl.autoAlignAxis(toSuperviewAxis: .vertical);
        pageControl.autoAlignAxis(.horizontal, toSameAxisOf: leftButton);
        rightButton.autoPinEdge(.left, to: .right, of: pageControl);
        rightButton.autoPinEdge(toSuperviewEdge: .bottom);
        rightButton.autoPinEdge(toSuperviewEdge: .top, withInset: 7);
        
        pageNumberLabel.autoAlignAxis(.vertical, toSameAxisOf: pageControl);
        pageControl.autoPinEdge(.top, to: .bottom, of: pageNumberLabel, withOffset: -4);
        
        return view;
    }()
    
    private lazy var leftButton: MDCButton = {
        let button = MDCButton();
        button.accessibilityLabel = "previous_feature";
        button.setImage(UIImage(systemName: "chevron.left")?.aspectResize(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), for: .normal);
        button.autoSetDimensions(to: CGSize(width: 40, height: 40));
        button.setInsets(forContentPadding: UIEdgeInsets.zero, imageTitlePadding: 0);
        button.inkMaxRippleRadius = 20;
        button.inkStyle = .unbounded;
        button.addTarget(self, action: #selector(leftButtonTap), for: .touchUpInside);
        return button;
    }()
    
    private lazy var rightButton: MDCButton = {
        let button = MDCButton();
        button.accessibilityLabel = "next_feature";
        button.setImage(UIImage(systemName: "chevron.right")?.aspectResize(to: CGSize(width: 24, height: 24)).withRenderingMode(.alwaysTemplate), for: .normal);
        button.autoSetDimensions(to: CGSize(width: 40, height: 40));
        button.setInsets(forContentPadding: UIEdgeInsets.zero, imageTitlePadding: 0);
        button.inkMaxRippleRadius = 20;
        button.inkStyle = .unbounded;
        button.addTarget(self, action: #selector(rightButtonTap), for: .touchUpInside);
        return button;
    }()
    
    private lazy var drag: UIView = {
        let drag = UIView(forAutoLayout: ());
        drag.autoSetDimensions(to: CGSize(width: 50, height: 7));
        drag.clipsToBounds = true;
        drag.layer.cornerRadius = 3.5;
        return drag;
    }()
    
    private lazy var dragHandleView: UIView = {
        let view = UIView(forAutoLayout: ());
        view.addSubview(drag);
        drag.autoAlignAxis(toSuperviewAxis: .vertical);
        drag.autoPinEdge(toSuperviewEdge: .bottom);
        drag.autoPinEdge(toSuperviewEdge: .top, withInset: 7);
        return view;
    }()
    
    deinit {
        items.removeAll()
    }
    
    init(frame: CGRect) {
        super.init(nibName: nil, bundle: nil);
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    convenience init(items: [BottomSheetItem], mapView: MKMapView?, scheme: MarlinScheme?) {
        self.init(frame: CGRect.zero);
        self.scheme = scheme;
        self.items = items;
        self.mapView = mapView
        pageControl.numberOfPages = items.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (items.count > 1) {
            stackView.addArrangedSubview(pageControlHolder);
        } else {
            stackView.addArrangedSubview(dragHandleView);
        }
        
        scrollView.addSubview(stackView);
        self.view.addSubview(scrollView);
        
        applyTheme(withScheme: scheme?.containerScheme);
        
        populateView();
        
        view.setNeedsUpdateConstraints();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    func applyTheme(withScheme scheme: MDCContainerScheming? = nil) {
        guard let scheme = scheme else {
            return;
        }
        self.view.backgroundColor = scheme.colorScheme.surfaceColor;
        
        leftButton.applyTextTheme(withScheme: scheme);
        leftButton.tintColor = scheme.colorScheme.primaryColorVariant;
        rightButton.applyTextTheme(withScheme: scheme);
        rightButton.tintColor = scheme.colorScheme.primaryColorVariant;
        
        drag.backgroundColor = scheme.colorScheme.onSurfaceColor.withAlphaComponent(0.6)
        
        pageControl.pageIndicatorTintColor = scheme.colorScheme.onSurfaceColor.withAlphaComponent(0.6);
        pageControl.currentPageIndicatorTintColor = scheme.colorScheme.primaryColorVariant;
        pageNumberLabel.textColor = scheme.colorScheme.onSurfaceColor.withAlphaComponent(0.6);
        pageNumberLabel.font = scheme.typographyScheme.caption;
    }
    
    @objc func leftButtonTap() {
        // allow MDCButton ink ripple
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            self.pageControl.currentPage = self.pageControl.currentPage - 1
            self.populateView()
        }
    }
    
    @objc func rightButtonTap() {
        // allow MDCButton ink ripple
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            self.pageControl.currentPage = self.pageControl.currentPage + 1
            self.populateView()
        }
    }
    
    @objc func pageControlChangedValue() {
        self.populateView()
    }
    
    override func updateViewConstraints() {
        if (!didSetUpConstraints) {
            scrollView.autoPinEdge(toSuperviewEdge: .top);
            scrollView.autoPinEdge(toSuperviewEdge: .bottom);
            
            stackView.autoPinEdge(toSuperviewEdge: .left)
            stackView.autoPinEdge(toSuperviewEdge: .right)
            stackView.autoPinEdge(toSuperviewEdge: .top)
            stackView.autoPinEdge(toSuperviewMargin: .bottom)
            stackView.autoMatch(.width, to: .width, of: scrollView);
            stackView.autoAlignAxis(toSuperviewAxis: .vertical)
            didSetUpConstraints = true;
        }
        
        leftConstraint?.autoRemove();
        rightConstraint?.autoRemove();
        if (self.traitCollection.horizontalSizeClass == .regular) {
            leftConstraint = scrollView.autoPinEdge(toSuperviewMargin: .left);
            rightConstraint = scrollView.autoPinEdge(toSuperviewMargin: .right);
        } else {
            leftConstraint = scrollView.autoPinEdge(toSuperviewEdge: .left);
            rightConstraint = scrollView.autoPinEdge(toSuperviewEdge: .right);
        }
        
        super.updateViewConstraints();
    }
    
    func populateView() {
        let item = self.items[self.pageControl.currentPage];
        NotificationCenter.default.post(name: .MapAnnotationFocused, object: MapAnnotationFocusedNotification(annotation: item.annotationView?.annotation, mapView: mapView))
        
        UIView.transition(with: self.view, duration: 0.3, options: .transitionCrossDissolve, animations: {
            if self.currentAsamBottomSheetView?.view.superview != nil {
                self.currentAsamBottomSheetView?.view.removeFromSuperview();
            }
            if self.currentModuBottomSheetView?.view.superview != nil {
                self.currentModuBottomSheetView?.view.removeFromSuperview();
            }
            if self.currentLightBottomSheetView?.view.superview != nil {
                self.currentLightBottomSheetView?.view.removeFromSuperview();
            }
            self.currentAsamBottomSheetView = nil
            self.currentModuBottomSheetView = nil
            self.currentLightBottomSheetView = nil
            
            self.pageNumberLabel.text = "\(self.pageControl.currentPage+1) of \(self.pageControl.numberOfPages)";
            
            if let bottomSheetItem = item.item as? Asam {
                let asamBottomSheet = AsamBottomSheetViewController(asam: bottomSheetItem, scheme: self.scheme!)
                self.currentAsamBottomSheetView = asamBottomSheet
                self.stackView.addArrangedSubview(self.currentAsamBottomSheetView!.view);
            } else if let bottomSheetItem = item.item as? Modu {
                let moduBottomSheet = ModuBottomSheetViewController(modu: bottomSheetItem, scheme: self.scheme!)
                self.currentModuBottomSheetView = moduBottomSheet
                self.stackView.addArrangedSubview(self.currentModuBottomSheetView!.view);
            } else if let bottomSheetItem = item.item as? Light {
                let lightBottomSheet = LightBottomSheetViewController(light: bottomSheetItem, scheme: self.scheme!)
                self.currentLightBottomSheetView = lightBottomSheet
                self.stackView.addArrangedSubview(self.currentLightBottomSheetView!.view);
            }
            self.view.setNeedsUpdateConstraints();
        }, completion: nil)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.view.setNeedsUpdateConstraints()
    }
}

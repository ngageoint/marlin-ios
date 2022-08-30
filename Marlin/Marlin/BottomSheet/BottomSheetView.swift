//
//  BottomSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation

import SwiftUI

struct MarlinBottomSheet: View {
    @ObservedObject var itemList: BottomSheetItemList
    @State var selectedItem: Int = 0
    @EnvironmentObject var locationManager: LocationManager
    
    var pages: Int { itemList.bottomSheetItems?.count ?? 0 }
    
    @ViewBuilder
    private var rectangle: some View {
        Rectangle()
            .fill(Color(itemList.bottomSheetItems?[selectedItem].item.color ?? .clear))
            .frame(maxWidth: 6, maxHeight: .infinity)
    }
    
    var body: some View {
        VStack {
            if let bottomSheetItems = itemList.bottomSheetItems {
                if bottomSheetItems.count > 1 {
                    HStack(spacing: 8) {
                        Button(action: {
                            withAnimation {
                                selectedItem = max(0, selectedItem - 1)
                            }
                        }) {
                            Label(
                                title: {},
                                icon: { Image(systemName: "chevron.left")
                                        .renderingMode(.template)
                                        .foregroundColor(selectedItem != 0 ? Color.primaryColorVariant : Color.disabledColor)
                                })
                        }
                        .buttonStyle(MaterialButtonStyle())
                    
                        Text("\(selectedItem + 1) of \(pages)")
                            .font(Font.caption)
                            .foregroundColor(Color.onSurfaceColor.opacity(0.6))
                        
                        Button(action: {
                            withAnimation {
                                selectedItem = min(pages - 1, selectedItem + 1)
                            }
                        }) {
                            Label(
                                title: {},
                                icon: { Image(systemName: "chevron.right")
                                        .renderingMode(.template)
                                        .foregroundColor(pages - 1 != selectedItem ? Color.primaryColorVariant : Color.disabledColor)
                                })
                        }
                        .buttonStyle(MaterialButtonStyle())
                    }
                }
            
                if let item = itemList.bottomSheetItems?[selectedItem] {
                    if let asam = item.item as? Asam {
                        AsamSummaryView(asam: asam, showMoreDetails: true)
                            .transition(.opacity)
                    } else if let modu = item.item as? Modu {
                        ModuSummaryView(modu: modu, showMoreDetails: true)
                            .transition(.opacity)
                    } else if let light = item.item as? Light {
                        LightSummaryView(light: light, showMoreDetails: true)
                            .transition(.opacity)
                    } else if let port = item.item as? Port {
                        PortSummaryView(port: port, currentLocation: locationManager.lastLocation, showMoreDetails: true)
                            .transition(.opacity)
                    } else if let radioBeacon = item.item as? RadioBeacon {
                        RadioBeaconSummaryView(radioBeacon: radioBeacon, showMoreDetails: true)
                            .transition(.opacity)
                    } else if let differentialGPSStation = item.item as? DifferentialGPSStation {
                        DifferentialGPSStationSummaryView(differentialGPSStation: differentialGPSStation, showMoreDetails: true)
                            .transition(.opacity)
                    } else if let dfrs = item.item as? DFRS {
                        DFRSSummaryView(dfrs: dfrs, showMoreDetails: true)
                            .transition(.opacity)
                    }
                }
                    
            }
            Spacer()
        }
        .navigationBarHidden(true)
        .padding(.all, 16)
        .background(
            HStack {
                rectangle
                Spacer()
            }
            .ignoresSafeArea()
        )
        .onChange(of: selectedItem) { item in
            NotificationCenter.default.post(name: .MapAnnotationFocused, object: MapAnnotationFocusedNotification(annotation: itemList.bottomSheetItems?[item].annotationView?.annotation))
        }
        .onAppear {
            NotificationCenter.default.post(name: .MapAnnotationFocused, object: MapAnnotationFocusedNotification(annotation: itemList.bottomSheetItems?[selectedItem].annotationView?.annotation))
        }
    }
}

extension View {
    
    func bottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: BottomSheet.Detents = .mediumAndLarge,
        shouldScrollExpandSheet: Bool = false,
        largestUndimmedDetent: BottomSheet.LargestUndimmedDetent? = nil,
        showGrabber: Bool = false,
        cornerRadius: CGFloat? = nil,
        delegate: BottomSheetDelegate? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        background {
            Color.clear
                .onChange(of: isPresented.wrappedValue) { show in
                    if show {
                        BottomSheet.present(
                            detents: detents,
                            shouldScrollExpandSheet: shouldScrollExpandSheet,
                            largestUndimmedDetent: largestUndimmedDetent,
                            showGrabber: showGrabber,
                            cornerRadius: cornerRadius,
                            delegate: delegate
                        ) {
                            content()
                                .onDisappear {
                                    isPresented.projectedValue.wrappedValue = false
                                }
                        }
                    } else {
                        BottomSheet.dismiss()
                    }
                }
        }
    }
}

protocol BottomSheetDelegate {
    func bottomSheetDidDismiss()
}

struct BottomSheet {
    
    /// Wraps the UIKit's detents (UISheetPresentationController.Detent)
    public enum Detents: CaseIterable, Identifiable {
        
        /// Creates a system detent for a sheet that's approximately half the height of the screen, and is inactive in compact height.
        case medium
        /// Creates a system detent for a sheet at full height.
        case large
        /// Allows both medium and large detents. Opens in medium first
        case mediumAndLarge
        /// Allows both large and medium detents. Opens in large first
        case largeAndMedium
        
        fileprivate var value: [UISheetPresentationController.Detent] {
            switch self {
            case .medium:
                return [.medium()]
                
            case .large:
                return [.large()]
                
            case .mediumAndLarge, .largeAndMedium:
                return [.medium(), .large()]
            }
        }
        
        public var description: String {
            switch self {
            case .medium:
                return "Medium"
                
            case .large:
                return "Large"
                
            case .mediumAndLarge:
                return "Medium and large"
                
            case .largeAndMedium:
                return "Large and medium"
            }
        }
        
        public var id: Int {
            self.hashValue
        }
    }
    
    /// Wraps the UIKit's largestUndimmedDetentIdentifier.
    /// *"The largest detent that doesn’t dim the view underneath the sheet."*
    public enum LargestUndimmedDetent: CaseIterable, Identifiable {
        case medium
        case large
        
        fileprivate var value: UISheetPresentationController.Detent.Identifier {
            switch self {
            case .medium:
                return .medium
                
            case .large:
                return .large
            }
        }
        
        public var description: String {
            switch self {
            case .medium:
                return "Medium"
                
            case .large:
                return "Large"
            }
        }
        
        public var id: Int {
            self.hashValue
        }
    }
    
    private static var ref: UINavigationController? = nil
    private static var delegate: BottomSheetDelegate? = nil
    private static var presentationDelegate: BottomSheetPresentationDelegate? = nil
    
    public static func dismiss() {
        ref?.dismiss(animated: true, completion: {
            ref = nil
            delegate?.bottomSheetDidDismiss()
        })
    }

    fileprivate static func present<ContentView: View>(
        detents: Detents,
        shouldScrollExpandSheet: Bool,
        largestUndimmedDetent: LargestUndimmedDetent?,
        showGrabber: Bool,
        cornerRadius: CGFloat?,
        delegate: BottomSheetDelegate? = nil,
        @ViewBuilder _ contentView: @escaping () -> ContentView) {
            let detailViewController = UIHostingController(rootView: contentView())
            let nav = UINavigationController(rootViewController: detailViewController)
            
            ref = nav
            
            if let sheet = nav.sheetPresentationController {
                if let delegate = delegate {
                    presentationDelegate = BottomSheetPresentationDelegate(delegate: delegate)
                }
                sheet.delegate = presentationDelegate
                sheet.detents = detents.value
                sheet.prefersScrollingExpandsWhenScrolledToEdge = shouldScrollExpandSheet
                sheet.largestUndimmedDetentIdentifier = largestUndimmedDetent?.value ?? .none
                sheet.prefersGrabberVisible = showGrabber
                sheet.preferredCornerRadius = cornerRadius
                sheet.prefersEdgeAttachedInCompactHeight = true
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                switch detents {
                case .largeAndMedium:
                    sheet.selectedDetentIdentifier = .large
                    
                case .mediumAndLarge:
                    sheet.selectedDetentIdentifier = .medium
                    
                default: break
                }
            }
            
            UIApplication.shared.keyWindow?.rootViewController?.present(nav, animated: true, completion: nil)
    }
}

class BottomSheetPresentationDelegate : NSObject, UISheetPresentationControllerDelegate {
    var delegate: BottomSheetDelegate
    
    init(delegate: BottomSheetDelegate) {
        self.delegate = delegate
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        delegate.bottomSheetDidDismiss()
    }
}

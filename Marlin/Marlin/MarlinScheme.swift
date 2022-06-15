//
//  MarlinScheme.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import Foundation
import MaterialComponents

class MarlinScheme: ObservableObject {
    
    let containerScheme = MDCContainerScheme();
    
    init() {
        containerScheme.colorScheme.primaryColorVariant = UIColor(named: "primaryVariant") ?? MDCPalette.blue.tint600
        containerScheme.colorScheme.primaryColor = UIColor(named: "primary") ?? MDCPalette.blue.tint600
        containerScheme.colorScheme.secondaryColor = UIColor(named: "secondary") ?? (MDCPalette.orange.accent700 ?? .systemFill)
        containerScheme.colorScheme.onSecondaryColor = UIColor(named: "onSecondary") ?? .label
        containerScheme.colorScheme.surfaceColor = UIColor(named: "surface") ?? UIColor.systemBackground
        containerScheme.colorScheme.onSurfaceColor = UIColor.label
        containerScheme.colorScheme.backgroundColor = UIColor(named: "background") ?? UIColor.systemBackground
        containerScheme.colorScheme.onBackgroundColor = UIColor.label
        containerScheme.colorScheme.errorColor = .systemRed
        containerScheme.colorScheme.onPrimaryColor = UIColor(named: "onPrimary") ?? .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = containerScheme.colorScheme.primaryColor;
        
        appearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: containerScheme.colorScheme.onPrimaryColor,
            NSAttributedString.Key.backgroundColor: containerScheme.colorScheme.primaryColor
        ];
        appearance.largeTitleTextAttributes = [
            NSAttributedString.Key.foregroundColor: containerScheme.colorScheme.onPrimaryColor,
            NSAttributedString.Key.backgroundColor: containerScheme.colorScheme.primaryColor
        ];
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().compactScrollEdgeAppearance = appearance
        
        UINavigationBar.appearance().barTintColor = containerScheme.colorScheme.onPrimaryColor
        UINavigationBar.appearance().tintColor = containerScheme.colorScheme.onPrimaryColor
        UINavigationBar.appearance().prefersLargeTitles = false
    }
    
}

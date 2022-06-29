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
    let disabledScheme = MDCContainerScheme()
    
    init() {
        
        disabledScheme.colorScheme.primaryColorVariant = MDCPalette.grey.tint300;
        disabledScheme.colorScheme.primaryColor = MDCPalette.grey.tint300;
        disabledScheme.colorScheme.secondaryColor = MDCPalette.grey.tint300;
        disabledScheme.colorScheme.onSecondaryColor = MDCPalette.grey.tint500;
        disabledScheme.colorScheme.surfaceColor = MDCPalette.grey.tint300;
        disabledScheme.colorScheme.onSurfaceColor = MDCPalette.grey.tint500;
        disabledScheme.colorScheme.backgroundColor = MDCPalette.grey.tint300;
        disabledScheme.colorScheme.onBackgroundColor = MDCPalette.grey.tint500;
        disabledScheme.colorScheme.errorColor = .systemRed;
        disabledScheme.colorScheme.onPrimaryColor = MDCPalette.grey.tint500;
                
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
        
        UITableView.appearance().backgroundColor = containerScheme.colorScheme.backgroundColor
        
        let tabBarAppearance = UITabBarAppearance();
        tabBarAppearance.selectionIndicatorTintColor = containerScheme.colorScheme.primaryColorVariant.withAlphaComponent(0.87)
        tabBarAppearance.backgroundColor = containerScheme.colorScheme.surfaceColor
        setTabBarItemColors(tabBarAppearance.stackedLayoutAppearance, scheme: containerScheme)
        setTabBarItemColors(tabBarAppearance.inlineLayoutAppearance, scheme: containerScheme)
        setTabBarItemColors(tabBarAppearance.compactInlineLayoutAppearance, scheme: containerScheme)
        
        UITabBar.appearance().standardAppearance = tabBarAppearance;
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    private func setTabBarItemColors(_ itemAppearance: UITabBarItemAppearance, scheme: MDCContainerScheming) {
        itemAppearance.normal.iconColor = scheme.colorScheme.onBackgroundColor.withAlphaComponent(0.6);
        itemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: scheme.colorScheme.onBackgroundColor.withAlphaComponent(0.6)]
        
        itemAppearance.selected.iconColor = scheme.colorScheme.primaryColorVariant.withAlphaComponent(0.87)
        itemAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor: scheme.colorScheme.primaryColorVariant.withAlphaComponent(0.87)]
    }
    
}

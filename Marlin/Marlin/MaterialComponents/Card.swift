//
//  Card.swift
//  Marlin
//
//  Created by Daniel Barela on 6/15/22.
//

import Foundation
import SwiftUI

struct CardModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .background(Color.surfaceColor)
            .cornerRadius(12)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
    }

}

extension View {
    func card() -> some View {
        modifier(CardModifier())
    }
}

struct PaddedCardModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color.surfaceColor)
            .cornerRadius(12)
            .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)
    }

}

extension View {
    func paddedCard() -> some View {
        modifier(PaddedCardModifier())
    }
}

struct UnreadModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding(.top, 16)
            .padding(.bottom, 16)
            .padding(.leading, 24)
            .padding(.trailing, 24)
            .font(Font.body2)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.primaryColor)
                    .padding(8)
                    .shadow(color: Color(UIColor.label).opacity(0.5), radius: 1, x: 0, y: 1)

            )
            .foregroundColor(Color.onPrimaryColor)

    }

}

struct OverlineModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.overline)
            .foregroundColor(Color.onSurfaceColor)
            .opacity(0.45)
    }
}

extension View {
    func overline() -> some View {
        modifier(OverlineModifier())
    }
}

struct ItemTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.headline5.weight(.heavy))
    }
}

extension View {
    func itemTitle() -> some View {
        modifier(ItemTitleModifier())
    }
}

struct PrimaryModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.headline6)
            .foregroundColor(Color.onSurfaceColor)
            .opacity(0.87)
    }
}

extension View {
    func primary() -> some View {
        modifier(PrimaryModifier())
    }
}

struct SecondaryModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Font.body2)
            .foregroundColor(Color.onSurfaceColor)
            .opacity(0.6)
    }
}

extension View {
    func secondary() -> some View {
        modifier(SecondaryModifier())
    }
}

struct DataSourceSummaryItemModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
    }
}

extension View {
    func dataSourceSummaryItem() -> some View {
        modifier(DataSourceSummaryItemModifier())
    }
}

struct DataSourceItemSummaryListModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding([.leading, .trailing], 0)
            .listStyle(.plain)
            .background(Color.backgroundColor)
            .complexModifier {
                if #available(iOS 16, *) {
                    $0.scrollContentBackground(.hidden)
                } else {
                    $0
                }
            }
    }
}

extension View {
    func dataSourceSummaryList() -> some View {
        modifier(DataSourceItemSummaryListModifier())
    }
}

struct DataSourceItemSectionModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowInsets(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
            .listRowBackground(Color.backgroundColor)
            .listRowSeparator(.hidden)
    }
}

extension View {
    func dataSourceSection() -> some View {
        modifier(DataSourceItemSectionModifier())
    }
}

struct DataSourceItemDetailListModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding([.leading, .trailing], 0)
            .listStyle(.plain)
            .background(Color.backgroundColor)
            .scrollContentBackground(.hidden)
    }
}

extension View {
    func sectionHeader() -> some View {
        modifier(SectionHeaderModifier())
    }
}

struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
        // TODO: for now; this should be removed to match what apple wants for section headers
            .foregroundColor(Color.onBackgroundColor.opacity(0.45))
            .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 0, trailing: 8))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.backgroundColor)
    }
}

extension View {
    func dataSourceDetailList() -> some View {
        modifier(DataSourceItemDetailListModifier())
    }
}

struct GradientViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .tint(Color.onPrimaryColor)
            .foregroundColor(Color.onPrimaryColor)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [.secondaryColor, .primaryColor]),
                    startPoint: .bottom,
                    endPoint: UnitPoint(x: 0.5, y: 0.37)
                )
            )
    }
}

extension View {
    func gradientView() -> some View {
        modifier(GradientViewModifier())
    }
}

struct InverseGradientViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .tint(Color.onPrimaryColor)
            .foregroundColor(Color.onPrimaryColor)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [.primaryColor, .secondaryColor]),
                    startPoint: .bottom,
                    endPoint: UnitPoint(x: 0.5, y: -0.5)
                )
            )
    }
}

extension View {
    func inverseGradientView() -> some View {
        modifier(InverseGradientViewModifier())
    }
}

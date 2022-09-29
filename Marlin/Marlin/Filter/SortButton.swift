//
//  SortButton.swift
//  Marlin
//
//  Created by Daniel Barela on 9/28/22.
//

import SwiftUI

struct SortButton: ViewModifier {
    @AppStorage("sortEnabled") var sortEnabled = false
    
    @Binding var sortOpen: Bool
    @Binding var dataSource: DataSourceItem
    
    init(sortOpen: Binding<Bool>, dataSource: Binding<DataSourceItem>) {
        self._sortOpen = sortOpen
        self._dataSource = dataSource
    }
    
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem (placement: .navigationBarTrailing)  {
                if sortEnabled {
                    HStack {
                        Button(action: {
                            sortOpen.toggle()
                        }) {
                            Image(systemName: "arrow.up.arrow.down")
                                .imageScale(.large)
                                .foregroundColor(Color.onPrimaryColor)
                        }
                        .padding(.all, 10)
                    }
                }
            }
        }
    }
}

//
//  SearchSheetView.swift
//  Marlin
//
//  Created by Daniel Barela on 3/11/24.
//

import Foundation
import SwiftUI

struct SearchSheetView: View {
    @EnvironmentObject var searchRepository: SearchRepository
    var itemKey: String
    var focusNotification: NSNotification.Name

    @StateObject var viewModel: SearchViewModel = SearchViewModel()

    var body: some View {
        VStack {
            if let model = viewModel.searchResult {
                VStack {
                    Text(model.displayName)
                    Button {
                        print("hi")
                    } label: {
                        Text("Save To My Places")
                    }
                    .buttonStyle(MaterialButtonStyle(type: .contained))

                }
            }
        }
        .onChange(of: itemKey) { newItemKey in
            viewModel.repository = searchRepository
            viewModel.getItem(id: newItemKey)
        }
        .onAppear {
            viewModel.repository = searchRepository
            viewModel.getItem(id: itemKey)
        }
        .onChange(of: viewModel.searchResult) { model in
            NotificationCenter.default.post(
                name: focusNotification,
                object: FocusMapOnItemNotification(
                    item: model,
                    definition: DataSources.search
                )
            )
        }
    }
}

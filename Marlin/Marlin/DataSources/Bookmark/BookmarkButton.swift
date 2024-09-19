//
//  BookmarkButton.swift
//  Marlin
//
//  Created by Daniel Barela on 7/27/23.
//

import SwiftUI

@MainActor
struct BookmarkButton: View {
    var action: Actions.Bookmark
    
    @State var notes: String = ""
    
    var body: some View {
        Button(action: action.action) {
            Label(
                title: { },
                icon: { Image(systemName: action.bookmarkViewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                        .renderingMode(.template)
                        .foregroundColor(Color.primaryColorVariant)
                })
        }
        .accessibilityElement()
        .accessibilityLabel(
            """
            \(action.bookmarkViewModel.isBookmarked ? "remove bookmark \(action.bookmarkViewModel.itemKey ?? "")"
            : "bookmark")
            """
        )
        .animation(.easeOut, value: action.bookmarkViewModel.isBookmarked)
        .sheet(isPresented: action.$bookmarkViewModel.bookmarkBottomSheet) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "bookmark.fill")
                        .renderingMode(.template)
                        .foregroundColor(Color.onSurfaceColor)
                    Text("Bookmark Notes")
                        .primary()
                }
                TextEditor(text: action.$bookmarkViewModel.bnotes)
                    .lineLimit(4...)
                    .overlay(
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color.primaryColorVariant),
                        alignment: .bottom
                    )
                    .scrollContentBackground(.hidden)
                    .background(Color.backgroundColor)
                    .tint(Color.primaryColorVariant)
                    .accessibilityElement()
                    .accessibilityLabel("notes")
                HStack {
                    Spacer()
                    Button("Bookmark") {
                        withAnimation {
                            action.bookmarkViewModel.createBookmark(notes: action.bookmarkViewModel.bnotes)
                        }
                        action.bookmarkViewModel.bookmarkBottomSheet = false
                    }
                    .buttonStyle(MaterialButtonStyle(type: .text))
                    .accessibilityElement()
                    .accessibilityLabel("Bookmark")
                }
            }
            .padding(.all, 16)
            .presentationDetents([.height(200)])
        }
    }
}

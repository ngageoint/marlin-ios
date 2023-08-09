//
//  BookmarkButton.swift
//  Marlin
//
//  Created by Daniel Barela on 7/27/23.
//

import SwiftUI

struct BookmarkButton: View {
    @State var bookmarkBottomSheet: Bool = false
    @State var notes: String = ""
    @ObservedObject var viewModel: BookmarkViewModel
    
    var body: some View {
        Button(action: {
            withAnimation {
                if viewModel.isBookmarked {
                    viewModel.removeBookmark()
                } else {
                    bookmarkBottomSheet = true
                }
            }
        }) {
            Label(
                title: { },
                icon: { Image(systemName: viewModel.isBookmarked ? "bookmark.fill" : "bookmark")
                        .renderingMode(.template)
                        .foregroundColor(Color.primaryColorVariant)
                })
        }
        .accessibilityElement()
        .accessibilityLabel("\(viewModel.isBookmarked ? "remove bookmark" : "bookmark")")
        .animation(.easeOut, value: viewModel.isBookmarked)
        .sheet(isPresented: $bookmarkBottomSheet) {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "bookmark.fill")
                        .renderingMode(.template)
                        .foregroundColor(Color.onSurfaceColor)
                    Text("Bookmark Notes")
                        .primary()
                }
                TextEditor(text: $notes)
                    .lineLimit(4...)
                    .overlay(Rectangle().frame(height: 2).foregroundColor(Color.primaryColorVariant), alignment: .bottom)
                    .scrollContentBackground(.hidden)
                    .background(Color.backgroundColor)
                    .tint(Color.primaryColorVariant)
                    .accessibilityElement()
                    .accessibilityLabel("notes")
                HStack {
                    Spacer()
                    Button("Bookmark") {
                        withAnimation {
                            viewModel.createBookmark(notes: notes)
                        }
                        bookmarkBottomSheet = false
                    }
                    .buttonStyle(MaterialButtonStyle(type:.text))
                    .accessibilityElement()
                    .accessibilityLabel("Bookmark")
                }
            }
            .padding(.all, 16)
            .presentationDetents([.height(200)])
        }
    }
}

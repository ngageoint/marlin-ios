//
//  BookmarkButton.swift
//  Marlin
//
//  Created by Daniel Barela on 7/27/23.
//

import SwiftUI

struct BookmarkButton: View {
    var dataSource: any DataSource
    @State var bookmarkBottomSheet: Bool = false
    @State var notes: String = ""
    @ObservedObject var viewModel: BookmarkViewModel = BookmarkViewModel()
    
    var body: some View {
        Group {
            if viewModel.bookmark != nil {
                Button(action: {
                    viewModel.removeBookmark()
                }) {
                    Label(
                        title: {},
                        icon: { Image(systemName: "bookmark.fill")
                                .renderingMode(.template)
                                .foregroundColor(Color.primaryColorVariant)
                        })
                }
                .accessibilityElement()
                .accessibilityLabel("bookmark")
                .transition(.opacity.animation(.easeOut))
            } else {
                Button(action: {
                    bookmarkBottomSheet = true
                }) {
                    Label(
                        title: {},
                        icon: { Image(systemName: "bookmark")
                                .renderingMode(.template)
                                .foregroundColor(Color.primaryColorVariant)
                        })
                }
                .accessibilityElement()
                .accessibilityLabel("bookmark")
                .transition(.opacity.animation(.easeOut))
            }
        }
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
                    .background(Color.backgroundColor)
                    .tint(Color.primaryColorVariant)
                HStack {
                    Spacer()
                    Button("Bookmark") {
                        viewModel.createBookmark(notes: notes)
                        bookmarkBottomSheet = false
                    }
                    .buttonStyle(MaterialButtonStyle(type:.text))
                }
            }
            .padding(.all, 16)
            .presentationDetents([.height(200)])
        }
        .onAppear {
            viewModel.dataSource = dataSource
        }
    }
}

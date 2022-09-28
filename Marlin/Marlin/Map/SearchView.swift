//
//  SearchView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/20/22.
//

import SwiftUI

struct SearchView: View {
    @AppStorage("searchEnabled") var searchEnabled: Bool = false
    @State var search: String = ""
    @AppStorage("searchExpanded") var searchExpanded: Bool = false
    
    var body: some View {
        if searchEnabled {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center, spacing: 0) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .frame(width: 24, height: 24, alignment: .center)
                        .onTapGesture {
                            searchExpanded.toggle()
                        }
                    TextField("Search", text: $search)
                        .frame(maxWidth: searchExpanded ? .infinity : 0)
                    //                Button("GO") {
                    //                    print("Go")
                    //                }
                    //                .padding([.trailing, .leading], 8)
                    //                .font(Font.caption)
                    //                .frame(width: 40, height: 40, alignment: .center)
                    //                .foregroundColor(Color.onPrimaryColor)
                    //                .background(
                    //                    RoundedRectangle(cornerRadius: 20).fill(Color.primaryColor)
                    //                )
                    //                .offset(x: 8)
                    
//                    Button("SEARCH") {
//                        print("Go")
//                    }
//                    .padding([.trailing, .leading], 8)
//                    .font(Font.caption)
//                    .frame(height: 40, alignment: .center)
//                    .foregroundColor(Color.onPrimaryColor)
//                    .background(
//                        RoundedRectangle(cornerRadius: 20).fill(Color.primaryColor)
//                    )
//                    .offset(x: 8)
                }
//                Divider()
//                LazyVStack(alignment: .leading) {
//                    Text("Search result 1")
//                        .font(Font.body1)
//                    Divider()
//                    Text("search result 2")
//                        .font(Font.body1)
//                    Divider()
//                }
//                .padding(.top, 8)
            }
            .frame(minWidth: 40, maxWidth: searchExpanded ? .infinity : 40, minHeight: 40)
            .padding([.leading, .trailing], searchExpanded ? 8 : 0)
            .font(Font.body2)
            .foregroundColor(Color.primaryColorVariant)
            .background(
                RoundedRectangle(cornerRadius: 20).fill(Color.surfaceColor).shadow(color: Color(.sRGB, white: 0, opacity: 0.4), radius: 3, x: 0, y: 4)
            )
            .animation(.default, value: searchExpanded)
            .offset(x: 8, y: 16)
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

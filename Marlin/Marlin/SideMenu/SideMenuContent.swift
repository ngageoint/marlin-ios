//
//  SideMenu.swift
//  Marlin
//
//  Created by Daniel Barela on 7/3/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct SideMenuContent: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @StateObject var model: SideMenuViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Color.primaryColor
                    .frame(maxWidth: .infinity, maxHeight: 80)
                HStack {
                    Text("Data Source \(horizontalSizeClass == .compact ? "Tabs" : "Rail Items") (Drag to reorder)")
                        .padding([.leading, .top, .bottom, .trailing], 8)
                        .overline()
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.backgroundColor)
                
                if model.dataSourceList.tabs.count != 0 {
                    ForEach(model.dataSourceList.tabs, id: \.self) { dataSource in
                        DataSourceCell(dataSourceItem: dataSource)
                            .accessibilityElement()
                            .accessibilityLabel("\(dataSource.dataSource.fullName) tab cell")
                            .overlay(
                                model.validDropTarget && model.draggedItem == dataSource.key 
                                ? Color.white.opacity(0.8) : Color.clear
                            )
                            .onDrag {
                                model.onDrag(dataSource: dataSource)
                            }
                            .onDrop(of: [.plainText], delegate: SideMenuDrop(item: dataSource, model: model))
                    }
                } else {
                    Text("Drag here to add a \(horizontalSizeClass == .compact ? "tabs" : "rail items")")
                        .padding([.leading, .top, .bottom, .trailing], 8)
                        .overline()
                        .frame(maxWidth: .infinity)
                        .onDrop(of: [.plainText], isTargeted: nil, perform: model.dropOnEmptyTabFirst)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .strokeBorder(Color.gray, style: StrokeStyle(dash: [10]))
                                .padding([.trailing, .leading], 8)
                                .background(Color.backgroundColor)
                                .onDrop(of: [.plainText], isTargeted: nil, perform: model.dropOnEmptyTabFirst)
                        )
                }
                HStack {
                    Text("""
                    Other Data Sources (Drag to add to \(horizontalSizeClass == .compact ? "tabs" : "rail items"))
                    """)
                    .padding([.leading, .top, .bottom, .trailing], 8)
                    .overline()
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.backgroundColor)
                
                if model.dataSourceList.nonTabs.count != 0 {
                    ForEach(model.dataSourceList.nonTabs, id: \.self) { dataSource in
                        DataSourceCell(dataSourceItem: dataSource)
                            .accessibilityElement()
                            .accessibilityLabel("\(dataSource.dataSource.fullName) nontab cell")
                            .overlay(
                                model.validDropTarget && model.draggedItem == dataSource.key
                                ? Color.white.opacity(0.8) : Color.clear
                            )
                            .onDrag {
                                model.onDrag(dataSource: dataSource)
                            }
                            .onDrop(of: [.plainText], delegate: SideMenuDrop(item: dataSource, model: model))
                    }
                } else {
                    Text("Drag here to remove a \(horizontalSizeClass == .compact ? "tab" : "rail item")")
                        .padding([.leading, .top, .bottom, .trailing], 8)
                        .overline()
                        .frame(maxWidth: .infinity)
                        .onDrop(of: [.plainText], isTargeted: nil, perform: model.dropOnEmptyNonTabFirst)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .strokeBorder(Color.gray, style: StrokeStyle(dash: [10]))
                                .padding([.trailing, .leading], 8)
                                .background(Color.backgroundColor)
                                .onDrop(of: [.plainText], isTargeted: nil, perform: model.dropOnEmptyNonTabFirst)
                        )
                }
                
                HStack {
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.backgroundColor)
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .center) {
                        Image(systemName: "doc.fill.badge.plus")
                            .tint(Color.onSurfaceColor)
                            .opacity(0.60)
                        Text("Submit Report to NGA")
                            .font(Font.body1)
                            .foregroundColor(Color.onSurfaceColor)
                            .opacity(0.87)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        NotificationCenter.default.post(name: .SwitchTabs, object: "submitReport")
                    }
                    .padding([.leading, .top, .bottom, .trailing], 16)
                    .accessibilityElement()
                    .accessibilityLabel("Submit Report to NGA")
                    Divider()
                }
                .background(Color.surfaceColor)
                HStack {
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.bottom, 8)
                .background(Color.backgroundColor)
                AboutCell()
                Spacer()
            }
            .frame(maxHeight: .infinity)
            .background(Color.backgroundColor)
            .ignoresSafeArea(.all, edges: [.top, .bottom])
            .onDrop(of: [.text], isTargeted: nil) { _ in
                model.draggedItem = nil
                model.validDropTarget = false
                return true
            }
        }
    }
}

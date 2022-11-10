//
//  SortView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/29/22.
//

import SwiftUI

struct SortView: View {
    
    @State var sort: [DataSourceSortParameter] {
        didSet {
            UserDefaults.standard.setSort(dataSource.key, sort: sort)
        }
    }
    
    var dataSourceProperties: [DataSourceProperty]
    var dataSource: any DataSource.Type
    
    @State private var selectedProperty: DataSourceProperty?
    @State private var ascending: Bool
    @State private var sections: Bool
    
    init(dataSource: any DataSource.Type) {
        self.dataSource = dataSource
        self.dataSourceProperties = dataSource.properties
        let userSort = UserDefaults.standard.sort(dataSource.key)
        if userSort.isEmpty {
            self._sort = State(initialValue: dataSource.defaultSort)
            self._sections = State(initialValue: dataSource.defaultSort[0].section)

        } else {
            self._sort = State(initialValue: userSort)
            self._sections = State(initialValue: userSort[0].section)
        }
        self._ascending = State(initialValue: true)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                HStack {
                    Text("Primary Sort Field")
                        .secondary()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing, .top], 16)
                if !sort.isEmpty, let sortProperty = sort[0] {
                    HStack {
                        Text("\(sortProperty.property.name) \(sortProperty.ascending ? "ascending" : "descending") \(sortProperty.section ? "section" : "")")
                            .primary()
                        Spacer()
                        Button {
                            sort.remove(at: 0)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .tint(Color.red)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.leading, 16)
                    .padding([.top, .bottom], 8)
                    Divider()
                    HStack {
                        Text("Secondary Sort Field")
                            .secondary()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 16)
                    .padding(.top, 8)
                }
                
                if sort.count > 1, let sortProperty = sort[1] {
                    HStack {
                        Text("\(sortProperty.property.name) \(sortProperty.ascending ? "ascending" : "descending") \(sortProperty.section ? "section" : "")")
                            .primary()
                        Spacer()
                        Button {
                            sort.remove(at: 1)
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .tint(Color.red)
                        }
                    }
                    .padding(.leading, 16)
                    .padding([.top, .bottom], 8)
                    .frame(maxWidth: .infinity)
                }
                
                if sort.count < 2, selectedProperty != nil {
                    HStack {
                        Picker("Property", selection: $selectedProperty) {
                            ForEach(dataSourceProperties.filter({ property in
                                if !sort.isEmpty {
                                    let sortProperty = sort[0]
                                    return property.key != sortProperty.property.key
                                }
                                return true
                            })) { property in
                                Text(property.name).tag(Optional(property))
                            }
                        }
                        .labelsHidden()
                        .tint(Color.primaryColorVariant)
                        
                        Picker("Direction", selection: $ascending) {
                            Text("Ascending").tag(true)
                            Text("Descending").tag(false)
                        }
                        .labelsHidden()
                        .tint(Color.primaryColorVariant)
                        
                        Spacer()
                        Button {
                            if let selectedProperty = selectedProperty {
                                sort.append(DataSourceSortParameter(property: selectedProperty, ascending: ascending, section: sections && sort.isEmpty))
                                self.selectedProperty = dataSourceProperties.filter({ property in
                                    if !sort.isEmpty {
                                        let sortProperty = sort[0]
                                        return property.key != sortProperty.property.key
                                    }
                                    return true
                                })[0]
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .tint(Color.green)
                        }
                    }
                    .padding([.leading], 8)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.trailing, 16)
            HStack {
                Spacer()
                Button {
                    sort = self.dataSource.defaultSort
                } label: {
                    Text("Reset to Default")
                }
                .buttonStyle(MaterialButtonStyle())
                .padding(.all, 16)
            }
            .frame(maxWidth: .infinity)
            .background(Color.backgroundColor)
            
            HStack {
                Toggle("Group by primary sort field", isOn: $sections)
                    .secondary()
            }
            .frame(maxWidth: .infinity)
            .padding(.all, 16)
        }
        .onChange(of: sections, perform: { newValue in
            if !sort.isEmpty {
                sort[0] = DataSourceSortParameter(property: sort[0].property, ascending: sort[0].ascending, section: newValue)
            }
        })
        .onAppear {
            self.selectedProperty = dataSourceProperties.filter({ property in
                if !sort.isEmpty {
                    let sortProperty = sort[0]
                    return property.key != sortProperty.property.key
                }
                return true
            })[0]
        }
    }
}

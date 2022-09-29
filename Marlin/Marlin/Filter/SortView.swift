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
    
    @State private var selectedProperty: DataSourceProperty
    @State private var ascending: Bool
    
    init(dataSource: any DataSource.Type) {
        self.dataSource = dataSource
        self.dataSourceProperties = dataSource.properties
        self._sort = State(initialValue: UserDefaults.standard.sort(dataSource.key))
        self._selectedProperty = State(initialValue: dataSourceProperties[0])
        self._ascending = State(initialValue: true)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Primary Sort Field")
                    .secondary()
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.all, 8)
            if !sort.isEmpty, let sortProperty = sort[0] {
                HStack {
                    Text("\(sortProperty.property.name) \(sortProperty.ascending ? "ascending" : "descending")")
                    Spacer()
                    Button {
                        sort.remove(at: 0)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .tint(Color.red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.all, 8)
                Divider()
                HStack {
                    Text("Secondary Sort Field")
                        .secondary()
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.all, 8)
            }

            if sort.count > 1, let sortProperty = sort[1] {
                HStack {
                    Text("\(sortProperty.property.name) \(sortProperty.ascending ? "ascending" : "descending")")
                    Spacer()
                    Button {
                        sort.remove(at: 1)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .tint(Color.red)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.all, 8)
                Divider()
            }
//            ForEach(Array(sort.enumerated()), id: \.element) { index, sortProperty in
//                HStack {
//                    Text("\(sortProperty.property.name) \(sortProperty.ascending ? "ascending" : "descending")")
//                    Spacer()
//                    Button {
//                        sort.remove(at: index)
//                    } label: {
//                        Image(systemName: "minus.circle.fill")
//                            .tint(Color.red)
//                    }
//                }
//                .padding([.top, .bottom], 8)
//                Divider()
//            }
//            .padding(.leading, 16)
            
            if sort.count < 2 {
                HStack {
                    
                    Picker("Property", selection: $selectedProperty) {
                        ForEach(dataSourceProperties) { property in
                            Text(property.name).tag(property)
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
                        sort.append(DataSourceSortParameter(property: selectedProperty, ascending: ascending))
                        self.selectedProperty = dataSourceProperties[0]
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .tint(Color.green)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.all, 8)
    }
}

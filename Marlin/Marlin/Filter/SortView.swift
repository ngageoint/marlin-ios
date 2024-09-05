//
//  SortView.swift
//  Marlin
//
//  Created by Daniel Barela on 9/29/22.
//

import SwiftUI

struct SortView: View {
    @ObservedObject var viewModel: SortViewModel

    init(definition: any DataSourceDefinition) {
        viewModel = SortViewModel(definition: definition)
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

                firstSortProperty()
                secondSortProperty()

                addSortProperty()
            }
            .padding(.trailing, 16)
            HStack {
                Spacer()
                Button {
                    viewModel.sort = viewModel.filterable?.defaultSort ?? []
                } label: {
                    Text("Reset to Default")
                }
                .buttonStyle(MaterialButtonStyle())
                .padding(.all, 16)
            }
            .frame(maxWidth: .infinity)
            .background(Color.backgroundColor)

            HStack {
                Toggle("Group by primary sort field", isOn: $viewModel.sections)
                    .secondary()
                    .tint(Color.primaryColor)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                viewModel.sections.toggle()
            }
            .frame(maxWidth: .infinity)
            .padding(.all, 16)
            .accessibilityElement()
            .accessibilityLabel("Group by primary sort field")
        }
    }

    @ViewBuilder
    func firstSortProperty() -> some View {
        if let sortProperty = viewModel.firstSortProperty {
            HStack {
                Text(sortProperty.display())
                    .primary()
                Spacer()
                Button {
                    viewModel.removeFirst()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .tint(Color.red)
                }
                .accessibilityElement()
                .accessibilityLabel("remove first sort property")
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
    }

    @ViewBuilder
    func secondSortProperty() -> some View {
        if let sortProperty = viewModel.secondSortProperty {
            HStack {
                Text(sortProperty.display())
                    .primary()
                Spacer()
                Button {
                    viewModel.removeSecond()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .tint(Color.red)
                }
                .accessibilityElement()
                .accessibilityLabel("remove second sort property")
            }
            .padding(.leading, 16)
            .padding([.top, .bottom], 8)
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    func addSortProperty() -> some View {
        if !viewModel.possibleSortProperties.isEmpty {
            HStack {
                Picker("Property", selection: $viewModel.selectedProperty) {
                    ForEach(viewModel.possibleSortProperties) { property in
                        Text(property.name).tag(Optional(property))
                    }
                }
                .fixedSize()
                .labelsHidden()
                .tint(Color.primaryColorVariant)

                Picker("Direction", selection: $viewModel.ascending) {
                    Text("Ascending").tag(true)
                    Text("Descending").tag(false)
                }
                .fixedSize()
                .labelsHidden()
                .tint(Color.primaryColorVariant)

                Spacer()
                    .background(Color.red)
                Button {
                    viewModel.addSortProperty()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .tint(Color.green)
                }
                .accessibilityElement()
                .accessibilityLabel("add sort property")
            }
            .padding([.leading], 8)
            .frame(maxWidth: .infinity)
        }
    }
}

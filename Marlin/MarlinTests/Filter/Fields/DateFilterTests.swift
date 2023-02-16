//
//  DateFilterTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/15/23.
//

import XCTest
import SwiftUI

@testable import Marlin

final class DateFilterTests: XCTestCase {

    // untestable until you can pick form a picker
    func xtestFilterChange() {
        class PassThrough: ObservableObject {
            var viewModel: DataSourcePropertyFilterViewModel?
            init() {
            }
        }
        
        struct Container: View {
            @ObservedObject var passThrough: PassThrough
            
            @ObservedObject var filterViewModel = FilterViewModel(dataSource: MockDataSource.self)
            @ObservedObject var dataSourcePropertyFilterViewModel = DataSourcePropertyFilterViewModel(dataSourceProperty: DataSourceProperty(name: "Date", key: "dateProperty", type: .date))
            
            init(passThrough: PassThrough) {
                self.passThrough = passThrough
                self.passThrough.viewModel = dataSourcePropertyFilterViewModel
            }
            
            var body: some View {
                NavigationView {
                    DateFilter(filterViewModel: filterViewModel, viewModel: dataSourcePropertyFilterViewModel)
                }
            }
        }
        
        let passThrough = PassThrough()
        let view = Container(passThrough: passThrough)
        
        let controller = UIHostingController(rootView: view)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
    }
}

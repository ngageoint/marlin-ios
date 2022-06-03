//
//  MSI.swift
//  Marlin
//
//  Created by Daniel Barela on 6/3/22.
//

import Foundation
import Alamofire

public class MSI {
    
    static let shared = MSI()
    lazy var configuration: URLSessionConfiguration = URLSessionConfiguration.af.default
    lazy var session: Session = {
        return Session(configuration: configuration)
    }()
    
    init() {
        loadAsams()
    }
    
    func loadAsams() {
        
        session.request(MSIRouter.readAsams())
            .validate()
            .responseData { response in
                // Do whatever you wnat with response
                print("response is \(response)")
            }
    }
}


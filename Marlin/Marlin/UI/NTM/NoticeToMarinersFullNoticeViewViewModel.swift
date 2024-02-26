//
//  NoticeToMarinersFullNoticeViewViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 12/7/22.
//

import Foundation
import SwiftUI
import Alamofire

class NoticeToMarinersFullNoticeViewViewModel: ObservableObject {
    
    var noticeNumber: Int?

    @Published var graphics: [String?: [NTMGraphics]] = [:]
    @Published var loadingGraphics = false

    @Published var notices: [NoticeToMarinersModel] = []

    func setupModel(noticeNumber: Int? = nil, noticeNumberString: String? = nil) {
        self.noticeNumber = noticeNumber
        if let noticeNumberString = noticeNumberString {
            let components = noticeNumberString.components(separatedBy: "/")
            if components.count == 2 {
                // notice to mariners that we can obtain only go back to 1999
                if components[1] == "99" {
                    if let noticeNumber =
                        Int("19\(components[1])\(String(format: "%02d", Int(components[0]) ?? 0))") {
                        self.noticeNumber = noticeNumber
                    }
                } else {
                    if let noticeNumber =
                        Int("20\(components[1])\(String(format: "%02d", Int(components[0]) ?? 0))") {
                        self.noticeNumber = noticeNumber
                    }
                }
            }
        }
        if let repository = repository {
            if let noticeNumber = noticeNumber {
                getNotices(noticeNumber: noticeNumber)
            }
        }
    }

    var repository: NoticeToMarinersRepository? {
        didSet {
            if let noticeNumber = noticeNumber {
                getNotices(noticeNumber: noticeNumber)
            }
        }
    }

    @discardableResult
    func getNotices(noticeNumber: Int) -> [NoticeToMarinersModel]? {
        notices = repository?.getNoticesToMariners(noticeNumber: noticeNumber) ?? []
        return notices
    }

    var sortedGraphicKeys: [String] {
        return graphics.keys.sorted {
            return $0 ?? "" < $1 ?? ""
        }.compactMap { $0 }
    }

    var noticeNumberString: String? {
        print("notice number string for notice number \(noticeNumber)")
        if let noticeNumber = noticeNumber {
            return "\(Int(noticeNumber / 100) % 100)/\(noticeNumber % 100)"
        }
        return nil
    }
    
//    init(noticeNumber: Int64? = nil, noticeNumberString: String? = nil) {
//        self.noticeNumber = noticeNumber
//        if let noticeNumberString = noticeNumberString {
//            let components = noticeNumberString.components(separatedBy: "/")
//            if components.count == 2 {
//                // notice to mariners that we can obtain only go back to 1999
//                if components[1] == "99" {
//                    if let noticeNumber = 
//                        Int64("19\(components[1])\(String(format: "%02d", Int(components[0]) ?? 0))") {
//                        self.noticeNumber = noticeNumber
//                    }
//                } else {
//                    if let noticeNumber = 
//                        Int64("20\(components[1])\(String(format: "%02d", Int(components[0]) ?? 0))") {
//                        self.noticeNumber = noticeNumber
//                    }
//                }
//            }
//        }
//    }
    
//    func createFetchRequest() -> FetchRequest<NoticeToMariners> {
//        if let predicate = predicate {
//            // Intialize the FetchRequest property wrapper
//            return FetchRequest(
//                entity: NoticeToMariners.entity(),
//                sortDescriptors: sortDescriptors,
//                predicate: predicate
//            )
//        } else {
//            return FetchRequest(
//                entity: NoticeToMariners.entity(),
//                sortDescriptors: sortDescriptors,
//                predicate: NSPredicate(value: false)
//            )
//        }
//    }
//    
    func createBookmarkFetchRequest() -> FetchRequest<Bookmark> {
        if let noticeNumber = noticeNumber {
            return FetchRequest(
                entity: Bookmark.entity(),
                sortDescriptors: [],
                predicate: NSPredicate(
                    format: "id == %@ AND dataSource == %@", "\(noticeNumber)", DataSources.noticeToMariners.key)
            )
        }
        return FetchRequest(entity: Bookmark.entity(), sortDescriptors: [], predicate: NSPredicate(value: false))
    }
    
    func loadGraphics() {
        let urlString = """
        \(MSIRouter.baseURLString)/publications/ntm/ntm-graphics?\
        noticeNumber=\(noticeNumber ?? 0)&graphicType=All&output=json
        """
        guard let url = URL(string: urlString) else {
            print("Your API end point is Invalid")
            return
        }
        loadingGraphics = true
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        
        MSI.shared.session.request(
            url,
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: nil,
            interceptor: nil,
            requestModifier: .none
        )
        .responseDecodable(of: NTMGraphicsPropertyContainer.self, queue: queue) { response in
            queue.async( execute: {
                Task.detached {
                    DispatchQueue.main.async {
                        self.loadingGraphics = false
                        if let error = response.error {
                            print("Graphic Load Error \(error.localizedDescription)")
                            return
                        }
                        self.graphics = Dictionary(grouping: response.value?.ntmGraphics ?? [], by: \.graphicType)
                    }
                }
            })
        }
    }
}

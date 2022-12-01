//
//  NoticeToMarinersFullNoticeView.swift
//  Marlin
//
//  Created by Daniel Barela on 11/15/22.
//

import SwiftUI
import Alamofire

struct NoticeToMarinersFullNoticeView: View {
    var noticeNumber: Int64?
    var noticeNumberString: String?
    
    @FetchRequest<NoticeToMariners>
    var noticeToMarinersPublications: FetchedResults<NoticeToMariners>
    
    private static let initialColumns = 3
    
    @State private var gridColumns = Array(repeating: GridItem(.flexible()), count: initialColumns)
    @State private var numColumns = initialColumns
    
    @State var graphics: [String? : [NTMGraphics]] = [:]
    @State var loadingGraphics = false
    
    init(noticeNumber: Int64? = nil, noticeNumberString: String? = nil) {
        self.noticeNumber = noticeNumber
        self.noticeNumberString = noticeNumberString
        var predicate: NSPredicate?
        
        var sortDescriptors: [NSSortDescriptor] = []
        for sortDescriptor in NoticeToMariners.defaultSort {
            sortDescriptors.append(sortDescriptor.toNSSortDescriptor())
        }

        if let noticeNumber = noticeNumber {
            self.noticeNumberString = "\(Int(noticeNumber / 100) % 1000)/\(noticeNumber % 100)"
            predicate = NSPredicate(format: "noticeNumber == %i", argumentArray: [noticeNumber])
        } else if let noticeNumberString = noticeNumberString {
            let components = noticeNumberString.components(separatedBy: "/")
            if components.count == 2 {
                // notice numbers only go back to 1999
                if components[1] == "99" {
                    if let noticeNumber = Int64("1999\(String(format: "%02d", Int(components[0]) ?? 0))") {
                        self.noticeNumber = noticeNumber
                        predicate = NSPredicate(format: "noticeNumber == %i", argumentArray: [noticeNumber])
                    }
                } else {
                    if let noticeNumber = Int64("20\(components[1])\(String(format: "%02d", Int(components[0]) ?? 0))") {
                        self.noticeNumber = noticeNumber
                        predicate = NSPredicate(format: "noticeNumber == %i", argumentArray: [noticeNumber])
                    }
                }
            }
        }
        if let predicate = predicate {
            //Intialize the FetchRequest property wrapper
            self._noticeToMarinersPublications = FetchRequest(entity: NoticeToMariners.entity(), sortDescriptors: sortDescriptors, predicate: predicate)
        } else {
            self._noticeToMarinersPublications = FetchRequest(entity: NoticeToMariners.entity(), sortDescriptors: sortDescriptors, predicate: NSPredicate(value: false))
        }
        
    }
    
    var body: some View {
        List {
            if !graphics.isEmpty {
                
                    
                let sortedKeys: [String] = graphics.keys.sorted {
                    return $0 ?? "" < $1 ?? ""
                }.compactMap { $0 }
                ForEach(Array(sortedKeys), id: \.self) { key in
                    if let items = graphics[key] {
                        if !items.isEmpty {
                            Section("\(items[0].graphicType ?? "Graphics")") {
                                LazyVGrid(columns: gridColumns) {
                                    ForEach(items) { item in
                                        VStack {
                                            AsyncImage(
                                                url: URL(string:item.graphicUrl)!,
                                                name: item.fileName ?? "image.png",
                                                placeholder: { Text("Loading ...").overline() },
                                                image: { Image(uiImage: $0).resizable() }
                                            )
                                            .aspectRatio(contentMode: .fit)
                                            Text("Chart \(item.chartNumber ?? "")").overline()
                                        }
                                    }
                                }
                            }
                            .padding(.all, 8)
                        }
                    }
                    
                }
                .dataSourceSection()
            }
            Section("Files") {
                ForEach(noticeToMarinersPublications) { ntm in
                    NoticeToMarinersSummaryView(noticeToMariners: ntm)
                        .padding(.all, 16)
                        .card()
                }
                .dataSourceSummaryItem()
            }
            .dataSourceSection()
        }
        .dataSourceDetailList()
        .navigationTitle("Notice \(noticeNumberString ?? "")")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadGraphics)
    }
    
    func loadGraphics() {
        guard let url = URL(string:"\(MSIRouter.baseURLString)/publications/ntm/ntm-graphics?noticeNumber=\(noticeNumber ?? 0)&graphicType=All&output=json") else {
            print("Your API end point is Invalid")
            return
        }
        loadingGraphics = true
//        queryError = nil
        let queue = DispatchQueue(label: "mil.nga.msi.Marlin.api", qos: .background)
        
        MSI.shared.session.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil, interceptor: nil, requestModifier: .none)
            .responseDecodable(of: NTMGraphicsPropertyContainer.self, queue: queue) { response in
                loadingGraphics = false
                if let error = response.error {
                    print("Graphic Load Error \(error.localizedDescription)")
//                    self.queryError = error.localizedDescription
                    return
                }
                queue.async( execute:{
                    Task.detached {
                        DispatchQueue.main.async {
                            loadingGraphics = false
                            self.graphics = Dictionary(grouping: response.value?.ntmGraphics ?? [], by: \.graphicType)
                        }
                    }
                })
            }
    }
}

struct NoticeToMarinersFullNoticeView_Previews: PreviewProvider {
    static var previews: some View {
        NoticeToMarinersFullNoticeView()
    }
}

//
//  NoticeToMarinersFullNoticeViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/24/23.
//

import XCTest
import OHHTTPStubs
import SwiftUI
import Combine

@testable import Marlin

@available(iOS 16.0, *)
final class NoticeToMarinersFullNoticeViewTests: XCTestCase {
    var cancellable = Set<AnyCancellable>()
    var persistentStore: PersistentStore = PersistenceController.shared
    let persistentStoreLoadedPub = NotificationCenter.default.publisher(for: .PersistentStoreLoaded)
        .receive(on: RunLoop.main)
    
    override func setUp(completion: @escaping (Error?) -> Void) {
        for item in DataSourceList().allTabs {
            UserDefaults.standard.initialDataLoaded = false
            UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource as! any BatchImportable.Type)
        }
        UserDefaults.standard.lastLoadDate = Date(timeIntervalSince1970: 0)
        
        UserDefaults.standard.setValue(Date(), forKey: "forceReloadDate")
        persistentStoreLoadedPub
            .removeDuplicates()
            .sink { output in
                completion(nil)
            }
            .store(in: &cancellable)
        persistentStore.reset()
    }
    
    override func tearDown() {
    }
    func testLoading() {
        var publicationTitles: [String] = []
        var newItem: NoticeToMariners?
        persistentStore.viewContext.performAndWait {
            let ntm = NoticeToMariners(context: persistentStore.viewContext)
            
            ntm.publicationIdentifier = 41791
            ntm.noticeNumber = 202247
            ntm.title = "Front Cover"
            ntm.odsKey = "16694429/SFH00000/UNTM/202247/Front_Cover.pdf"
            ntm.sectionOrder = 20
            ntm.limitedDist = false
            ntm.odsEntryId = 29431
            ntm.odsContentId = 16694429
            ntm.internalPath = "UNTM/202247"
            ntm.filenameBase = "Front_Cover"
            ntm.fileExtension = "pdf"
            ntm.fileSize = 63491
            ntm.isFullPublication = false
            ntm.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961+0000")
            ntm.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.961Z")
            publicationTitles.append(ntm.title!)

            let ntm2 = NoticeToMariners(context: persistentStore.viewContext)
            ntm2.publicationIdentifier = 41791
            ntm2.noticeNumber = 202247
            ntm2.title = "Important Information"
            ntm2.odsKey = "16694429/SFH00000/UNTM/202247/Important_Info.pdf"
            ntm2.sectionOrder = 30
            ntm2.limitedDist = false
            ntm2.odsEntryId = 29435
            ntm2.odsContentId = 16694429
            ntm2.internalPath = "UNTM/202247"
            ntm2.filenameBase = "Important_Info"
            ntm2.fileExtension = "pdf"
            ntm2.fileSize = 22352
            ntm2.isFullPublication = false
            ntm2.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:34.474+0000")
            ntm2.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:34.474Z")
            publicationTitles.append(ntm2.title!)
            
            let ntm3 = NoticeToMariners(context: persistentStore.viewContext)
            ntm3.publicationIdentifier = 41791
            ntm3.noticeNumber = 202247
            ntm3.title = "Explanation of Contents"
            ntm3.odsKey = "16694429/SFH00000/UNTM/202247/Explanation_of_Contents.pdf"
            ntm3.sectionOrder = 50
            ntm3.limitedDist = false
            ntm3.odsEntryId = 29429
            ntm3.odsContentId = 16694429
            ntm3.internalPath = "UNTM/202247"
            ntm3.filenameBase = "Explanation_of_Contents"
            ntm3.fileExtension = "pdf"
            ntm3.fileSize = 27918
            ntm3.isFullPublication = false
            ntm3.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.754+0000")
            ntm3.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.754Z")
            publicationTitles.append(ntm3.title!)

            let ntm4 = NoticeToMariners(context: persistentStore.viewContext)
            ntm4.publicationIdentifier = 41791
            ntm4.noticeNumber = 202247
            ntm4.title = "Marine Information Report and Suggestion Sheet"
            ntm4.odsKey = "16694429/SFH00000/UNTM/202247/Marine_Info_Sug_Sht.pdf"
            ntm4.sectionOrder = 60
            ntm4.limitedDist = false
            ntm4.odsEntryId = 29437
            ntm4.odsContentId = 16694429
            ntm4.internalPath = "UNTM/202247"
            ntm4.filenameBase = "Marine_Info_Sug_Sht"
            ntm4.fileExtension = "pdf"
            ntm4.fileSize = 61422
            ntm4.isFullPublication = false
            ntm4.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:34.771+0000")
            ntm4.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:34.771Z")
            publicationTitles.append(ntm4.title!)

            let ntm5 = NoticeToMariners(context: persistentStore.viewContext)
            ntm5.publicationIdentifier = 41791
            ntm5.noticeNumber = 202247
            ntm5.title = "Geographic Locator"
            ntm5.odsKey = "16694429/SFH00000/UNTM/202247/Geographic_Locator.pdf"
            ntm5.sectionOrder = 80
            ntm5.limitedDist = false
            ntm5.odsEntryId = 29433
            ntm5.odsContentId = 16694429
            ntm5.internalPath = "UNTM/202247"
            ntm5.filenameBase = "Geographic_Locator"
            ntm5.fileExtension = "pdf"
            ntm5.fileSize = 175640
            ntm5.isFullPublication = false
            ntm5.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:34.270+0000")
            ntm5.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:34.270Z")
            publicationTitles.append(ntm5.title!)

            let ntm6 = NoticeToMariners(context: persistentStore.viewContext)
            ntm6.publicationIdentifier = 41791
            ntm6.noticeNumber = 202247
            ntm6.title = "Back Cover"
            ntm6.odsKey = "16694429/SFH00000/UNTM/202247/Back_Cover.pdf"
            ntm6.sectionOrder = 90
            ntm6.limitedDist = false
            ntm6.odsEntryId = 29423
            ntm6.odsContentId = 16694429
            ntm6.internalPath = "UNTM/202247"
            ntm6.filenameBase = "Back_Cover"
            ntm6.fileExtension = "pdf"
            ntm6.fileSize = 29158
            ntm6.isFullPublication = false
            ntm6.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.018+0000")
            ntm6.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.018Z")
            publicationTitles.append(ntm6.title!)

            let ntm7 = NoticeToMariners(context: persistentStore.viewContext)
            ntm7.publicationIdentifier = 41791
            ntm7.noticeNumber = 202247
            ntm7.title = "Chart Corrections"
            ntm7.odsKey = "16694429/SFH00000/UNTM/202247/Chart_Cor.pdf"
            ntm7.sectionOrder = 120
            ntm7.limitedDist = false
            ntm7.odsEntryId = 29425
            ntm7.odsContentId = 16694429
            ntm7.internalPath = "UNTM/202247"
            ntm7.filenameBase = "Chart_Cor"
            ntm7.fileExtension = "pdf"
            ntm7.fileSize = 58485
            ntm7.isFullPublication = false
            ntm7.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.289+0000")
            ntm7.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.289Z")
            publicationTitles.append(ntm7.title!)

            let ntm8 = NoticeToMariners(context: persistentStore.viewContext)
            ntm8.publicationIdentifier = 41791
            ntm8.noticeNumber = 202247
            ntm8.title = "Charts Affected by Notice to Mariners"
            ntm8.odsKey = "16694429/SFH00000/UNTM/202247/Charts_A_NTM.pdf"
            ntm8.sectionOrder = 140
            ntm8.limitedDist = false
            ntm8.odsEntryId = 29427
            ntm8.odsContentId = 16694429
            ntm8.internalPath = "UNTM/202247"
            ntm8.filenameBase = "Charts_A_NTM"
            ntm8.fileExtension = "pdf"
            ntm8.fileSize = 62065
            ntm8.isFullPublication = false
            ntm8.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.521+0000")
            ntm8.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:33.521Z")
            publicationTitles.append(ntm8.title!)

            let ntm9 = NoticeToMariners(context: persistentStore.viewContext)
            ntm9.publicationIdentifier = 41791
            ntm9.noticeNumber = 202247
            ntm9.title = "Marine Information"
            ntm9.odsKey = "16694429/SFH00000/UNTM/202247/Marine_Info.pdf"
            ntm9.sectionOrder = 230
            ntm9.limitedDist = false
            ntm9.odsEntryId = 29439
            ntm9.odsContentId = 16694429
            ntm9.internalPath = "UNTM/202247"
            ntm9.filenameBase = "Marine_Info"
            ntm9.fileExtension = "pdf"
            ntm9.fileSize = 14049
            ntm9.isFullPublication = false
            ntm9.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:34.952+0000")
            ntm9.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:34.952Z")
            publicationTitles.append(ntm9.title!)

            let ntm10 = NoticeToMariners(context: persistentStore.viewContext)
            ntm10.publicationIdentifier = 41791
            ntm10.noticeNumber = 202247
            ntm10.title = "Entire NtM"
            ntm10.odsKey = "16694429/SFH00000/UNTM/202247/NtM_47-2022.pdf"
            ntm10.sectionOrder = 235
            ntm10.limitedDist = false
            ntm10.odsEntryId = 29441
            ntm10.odsContentId = 16694429
            ntm10.internalPath = "UNTM/202247"
            ntm10.filenameBase = "NtM_47-2022"
            ntm10.fileExtension = "pdf"
            ntm10.fileSize = 386414
            ntm10.isFullPublication = true
            ntm10.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:35.243+0000")
            ntm10.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:35.243Z")
            publicationTitles.append("\(ntm10.title!) pdf")
            
            let ntm11 = NoticeToMariners(context: persistentStore.viewContext)
            ntm11.publicationIdentifier = 41791
            ntm11.noticeNumber = 202247
            ntm11.title = "Entire NtM"
            ntm11.odsKey = "16694429/SFH00000/UNTM/202247/NtM_47-2022.zip"
            ntm11.sectionOrder = 235
            ntm11.limitedDist = false
            ntm11.odsEntryId = 29442
            ntm11.odsContentId = 16694429
            ntm11.internalPath = "UNTM/202247"
            ntm11.filenameBase = "NtM_47-2022"
            ntm11.fileExtension = "zip"
            ntm11.fileSize = 386414
            ntm11.isFullPublication = true
            ntm11.uploadTime = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:35.243+0000")
            ntm11.lastModified = NoticeToMariners.dateFormatter.date(from: "2022-11-08T12:28:35.243Z")
            publicationTitles.append("\(ntm11.title!) zip")

            newItem = ntm
            try? persistentStore.viewContext.save()
        }
        guard let newItem = newItem else {
            XCTFail()
            return
        }
                
        let pathToGraphicsFile = OHPathForFile("ntmGraphics.json", type(of: self))!
        let jsonData = try! Data(contentsOf: URL(filePath: pathToGraphicsFile))
        let jsonDict = try! JSONSerialization.jsonObject(with: jsonData) as! [String: Any]
        let ntmGraphics: [[String: Any]] = jsonDict["ntmGraphics"] as! [[String : Any]]
        var graphicsToLoad: [String] = []
        for graphic in ntmGraphics {
            graphicsToLoad.append(graphic["fileName"] as! String)
        }
        
        stub(condition: isScheme("https") && pathEndsWith("/publications/ntm/ntm-graphics") && containsQueryParams(["noticeNumber": "202247", "output":"json", "graphicType":"All"])) { request in
            return HTTPStubsResponse(
                fileAtPath: OHPathForFile("ntmGraphics.json", type(of: self))!,
                statusCode: 200,
                headers: ["Content-Type":"application/json"]
            )
        }
        
        stub(condition: isScheme("https") && pathEndsWith("publications/download")) { request in
            HTTPStubsResponse(data: TestHelpers.createGradientImage(startColor: UIColor(Color.ngaGreen), endColor: UIColor(Color.ngaBlue), size: CGSize(width: 50, height: 50)).jpegData(compressionQuality: 0.8)!, statusCode: 200, headers: ["Content-Type":"image/jpeg"])
        }
        
        let detailView = newItem.detailView.environment(\.managedObjectContext, persistentStore.viewContext)
        
        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        XCTAssertEqual(graphicsToLoad.count, 13)
        for load in graphicsToLoad {
            tester().waitForView(withAccessibilityLabel: load)
        }
        for title in publicationTitles {
            tester().waitForView(withAccessibilityLabel: title)
        }
        
        BookmarkHelper().verifyBookmarkButton(viewContext: persistentStore.viewContext, bookmarkable: newItem)
    }

}

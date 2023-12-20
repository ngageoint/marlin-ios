//
//  NoticeToMariners+CoreDataClass.swift
//  Marlin
//
//  Created by Daniel Barela on 11/14/22.
//

import Foundation
import CoreData
import UIKit

class NoticeToMariners: NSManagedObject, Downloadable {
    var error: String?

    var remoteLocation: URL? {
        guard let odsKey else {
            return nil
        }
        return URL(string: "\(MSIRouter.baseURLString)/publications/download?key=\(odsKey)&type=download")
    }
    
    var savePath: String {
        let docsUrl = URL.documentsDirectory
        return "\(docsUrl.absoluteString)\(odsKey ?? "")"
    }
        
    func checkFileExists() -> Bool {
        var downloaded = false
        if let destinationUrl = URL(string: self.savePath) {
            downloaded = FileManager().fileExists(atPath: destinationUrl.path)
        }
        if downloaded != self.isDownloaded {
            PersistenceController.current.perform {
                self.objectWillChange.send()
                self.isDownloaded = downloaded
                DispatchQueue.main.async {
                    try? PersistenceController.current.save()
                }
            }
        }
        return downloaded
    }
    
    func deleteFile() {
        guard let odsKey else {
            return
        }
        let docsUrl = URL.documentsDirectory
        let fileUrl = "\(docsUrl.absoluteString)\(odsKey)"
        let destinationUrl = URL(string: fileUrl)
        
        if let destinationUrl = destinationUrl {
            guard FileManager().fileExists(atPath: destinationUrl.path) else { return }
            do {
                try FileManager().removeItem(atPath: destinationUrl.path)
            } catch let error {
                print("Error while deleting file: ", error)
            }
        }
        
        PersistenceController.current.perform {
            self.objectWillChange.send()
            self.isDownloaded = false
            self.downloadProgress = 0.0
            DispatchQueue.main.async {
                try? PersistenceController.current.save()
            }
        }
    }

    var dateString: String? {
        if let date = uploadTime {
            return NoticeToMariners.dateFormatter.string(from: date)
        }
        return nil
    }
    
    override var description: String {
        return "Notice To Mariners\n\n"
    }
    
    func downloadFile() {
        if isDownloaded && checkFileExists() {
            return
        }
        DownloadManager.shared.download(downloadable: self)
    }
    
    func cancelDownload() {
        DownloadManager.shared.cancel(downloadable: self)
    }
    
    func getFirstDay(WeekNumber weekNumber: Int, CurrentYear currentYear: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dayComponent = DateComponents()
        dayComponent.weekOfYear = weekNumber
        dayComponent.weekday = 7
        dayComponent.yearForWeekOfYear = currentYear
        var date = calendar.date(from: dayComponent)!
        if weekNumber == 1 && calendar.component(.month, from: date) != 1 {
            dayComponent.year = currentYear - 1
            date = calendar.date(from: dayComponent)!
        }
        return date
        
    }
    
    func dateRange() -> String {
        let firstDate = getFirstDay(WeekNumber: Int(noticeNumber) % 100, CurrentYear: Int(noticeNumber / 100)) ?? Date()
        let lastDate = Calendar.current.date(byAdding: .day, value: 6, to: firstDate) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d"
        return "\(dateFormatter.string(from: firstDate)) - \(dateFormatter.string(from: lastDate))"
    }
}

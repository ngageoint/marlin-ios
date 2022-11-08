//
//  DownloadManager.swift
//  Marlin
//
//  Created by Daniel Barela on 10/26/22.
//

import Foundation
import AVKit
import OSLog

final class DownloadManager: NSObject {        
    var urlToDownloadableMap: [URL: Downloadable] = [:]
    
    static let shared: DownloadManager = DownloadManager()
    
    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: ElectronicPublication.backgroundDownloadIdentifier)
        config.isDiscretionary = false
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()
    
    private override init() {
        
    }
    
    func download(downloadable: Downloadable) {
        if downloadable.isDownloaded && downloadable.checkFileExists() {
            return
        }
        guard let requestUrl = downloadable.remoteLocation else {
            return
        }
        urlToDownloadableMap[requestUrl] = downloadable
        PersistenceController.current.perform {
            downloadable.objectWillChange.send()
            downloadable.isDownloading = true
            DispatchQueue.main.async {
                try? PersistenceController.current.save()
            }
        }
        if let destinationUrl = URL(string: downloadable.savePath) {
            if (FileManager().fileExists(atPath: destinationUrl.path)) {
                PersistenceController.current.perform {
                    downloadable.objectWillChange.send()
                    downloadable.isDownloading = false
                    downloadable.isDownloaded = true
                    DispatchQueue.main.async {
                        try? PersistenceController.current.save()
                    }
                }
            } else {
                let urlRequest = URLRequest(url: requestUrl)
                
                Metrics.shared.fileDownload(url: urlRequest.url)
                
                let downloadTask = urlSession.downloadTask(with: urlRequest)
                downloadTask.resume()
            }
        }
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        let logger = OSLog(subsystem: "Marlin", category: "background")
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                  let backgroundCompletionHandler =
                    appDelegate.backgroundCompletionHandler else {
                return
            }
            backgroundCompletionHandler()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.currentRequest?.url else {
            return
        }
        let downloadable = urlToDownloadableMap[url]
        PersistenceController.current.perform {
            downloadable?.objectWillChange.send()
            downloadable?.downloadProgress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            DispatchQueue.main.async {
                try? PersistenceController.current.save()
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        guard let url = downloadTask.currentRequest?.url, let downloadable = urlToDownloadableMap[url] else {
            return
        }

        guard let destinationUrl = URL(string: downloadable.savePath) else {
            return
        }
                
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print ("server error code \(downloadTask.response)")
            return
        }
        
        // just delete before saving again if it already exists
        if FileManager().fileExists(atPath: destinationUrl.path) {
            do {
                try FileManager().removeItem(atPath: destinationUrl.path)
            } catch {
                print("failed to delete file, it's fine")
            }
        }
        // create the directory structure
        do {
            try FileManager().createDirectory(atPath: destinationUrl.deletingLastPathComponent().path, withIntermediateDirectories: true)
        } catch {
            print("error making dir \(error) \(destinationUrl.deletingLastPathComponent().path)")
        }
        do {
            try FileManager.default.moveItem(at: location, to: destinationUrl)
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "Download Complete", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Downloaded the file \(downloadable.title)", arguments: nil)
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "mil.nga.msi"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
            let request = UNNotificationRequest.init(identifier: "downloadCompleted", content: content, trigger: trigger)
            
            // Schedule the notification.
            center.add(request)
            PersistenceController.current.perform {
                downloadable.objectWillChange.send()
                downloadable.isDownloaded = true
                downloadable.isDownloading = false
                downloadable.downloadProgress = 1.0
                DispatchQueue.main.async {
                    try? PersistenceController.current.save()
                }
            }
        } catch {
            print("error saving file to \(destinationUrl.path) \(error)")
        }
    }
}

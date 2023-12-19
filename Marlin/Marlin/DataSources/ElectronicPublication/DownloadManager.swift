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
    var urlToDownloadTask: [URL: URLSessionDownloadTask] = [:]
    
    static let shared: DownloadManager = DownloadManager()
    // since it is impossible to stub http requests on a background session, this is purely to be able
    // to override for testing
    var sessionConfig: URLSessionConfiguration = URLSessionConfiguration.background(withIdentifier: ElectronicPublication.backgroundDownloadIdentifier)
    
    private lazy var urlSession: URLSession = {
        sessionConfig.isDiscretionary = false
        sessionConfig.sessionSendsLaunchEvents = true
        return URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
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
            if FileManager().fileExists(atPath: destinationUrl.path) {
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
                urlToDownloadTask[requestUrl] = downloadTask
            }
        }
    }
    
    func cancel(downloadable: Downloadable) {
        guard let requestUrl = downloadable.remoteLocation else {
            return
        }
        let task = urlToDownloadTask[requestUrl]
        task?.cancel()
        urlToDownloadTask.removeValue(forKey: requestUrl)
        urlToDownloadableMap.removeValue(forKey: requestUrl)
        PersistenceController.current.perform {
            downloadable.objectWillChange.send()
            downloadable.isDownloading = false
            downloadable.isDownloaded = false
            DispatchQueue.main.async {
                try? PersistenceController.current.save()
            }
        }
    }
}

extension DownloadManager: URLSessionDownloadDelegate {
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                  let backgroundCompletionHandler =
                    appDelegate.backgroundCompletionHandler else {
                return
            }
            backgroundCompletionHandler()
        }
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        let protectionSpace = challenge.protectionSpace
        guard protectionSpace.authenticationMethod ==
                NSURLAuthenticationMethodServerTrust, let trust = protectionSpace.serverTrust else {
            return (.performDefaultHandling, nil)
        }
        do {
            guard let evaluator = try MSI.shared.manager.serverTrustEvaluator(forHost: protectionSpace.host) else {
                return (.performDefaultHandling, nil)
            }
            
            try evaluator.evaluate(trust, forHost: protectionSpace.host)
            
            return (URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        } catch {
            return (.cancelAuthenticationChallenge, nil)
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard let url = downloadTask.currentRequest?.url else {
            return
        }
        let downloadable = urlToDownloadableMap[url]
        downloadable?.managedObjectContext?.perform {
            downloadable?.objectWillChange.send()
            downloadable?.downloadProgress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
            try? downloadable?.managedObjectContext?.save()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.currentRequest?.url, let downloadable = urlToDownloadableMap[url] else {
            return
        }
        
        urlToDownloadTask.removeValue(forKey: url)
        urlToDownloadableMap.removeValue(forKey: url)
        
        var destinationUrl: URL?
        
        downloadable.managedObjectContext?.performAndWait {
            destinationUrl = URL(string: downloadable.savePath)
        }

        guard let destinationUrl = destinationUrl else {
            return
        }
        
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            print("server error code \(downloadTask.response.debugDescription)")
            if let httpResponse = downloadTask.response as? HTTPURLResponse {
                downloadable.managedObjectContext?.perform {
                    downloadable.objectWillChange.send()
                    downloadable.error = "Error downloading (\(httpResponse.statusCode))"
                    try? downloadable.managedObjectContext?.save()
                }
            }
            return
        }
        
        // just delete before saving again if it already exists
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            do {
                try FileManager.default.removeItem(atPath: destinationUrl.path)
            } catch {
                print("failed to delete file, it's fine")
            }
        }
        // create the directory structure
        do {
            try FileManager.default.createDirectory(atPath: destinationUrl.deletingLastPathComponent().path, withIntermediateDirectories: true)
        } catch {
            print("error making dir \(error) \(destinationUrl.deletingLastPathComponent().path)")
        }
        
        print("Does the file exist \(location.path)")
        if !FileManager.default.fileExists(atPath: location.path) {
            downloadable.managedObjectContext?.perform {
                downloadable.objectWillChange.send()
                downloadable.error = "Error downloading (file not saved)"
                try? downloadable.managedObjectContext?.save()
            }
            return
        }
        
        do {
            try FileManager.default.moveItem(at: location, to: destinationUrl)
            downloadable.managedObjectContext?.perform {
                let center = UNUserNotificationCenter.current()
                let content = UNMutableNotificationContent()
                content.title = NSString.localizedUserNotificationString(forKey: "Download Complete", arguments: nil)
                content.body = NSString.localizedUserNotificationString(forKey: "Downloaded the file \(downloadable.title ?? "")", arguments: nil)
                content.sound = UNNotificationSound.default
                content.categoryIdentifier = "mil.nga.msi"
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
                let request = UNNotificationRequest.init(identifier: "downloadCompleted", content: content, trigger: trigger)
                
                // Schedule the notification.
                center.add(request)
            
                downloadable.objectWillChange.send()
                downloadable.isDownloaded = true
                downloadable.isDownloading = false
                try? downloadable.managedObjectContext?.save()
            }
        } catch {
            print("error saving file to \(destinationUrl.path) \(error)")
        }
    }
}

//
//  DownloadManager.swift
//  Marlin
//
//  Created by Daniel Barela on 10/26/22.
//

import Foundation
import AVKit
import OSLog
import Combine

struct DownloadProgress {
    var id: String
    var isDownloading: Bool
    var isDownloaded: Bool
    var downloadProgress: Float
    var error: String
}

final class DownloadManager: NSObject {        
    var urlToDownloadableMap: [URL: Downloadable] = [:]
    var urlToDownloadTask: [URL: URLSessionDownloadTask] = [:]
    
//    static let shared: DownloadManager = DownloadManager()
    // since it is impossible to stub http requests on a background session, this is purely to be able
    // to override for testing
    var sessionConfig: URLSessionConfiguration = URLSessionConfiguration.background(
        withIdentifier: DataSources.epub.backgroundDownloadIdentifier
    )

    private lazy var urlSession: URLSession = {
        sessionConfig.isDiscretionary = false
        sessionConfig.sessionSendsLaunchEvents = true
        return URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
    }()

    let subject: PassthroughSubject<DownloadProgress, Never>
    let downloadable: Downloadable

    init(subject: PassthroughSubject<DownloadProgress, Never>, downloadable: Downloadable) {
        self.subject = subject
        self.downloadable = downloadable
        super.init()
    }
    
    func download() {
        guard let requestUrl = downloadable.remoteLocation else {
            return
        }
        urlToDownloadableMap[requestUrl] = downloadable
        print("download from \(requestUrl)")
        subject.send(
            DownloadProgress(
                id: downloadable.id,
                isDownloading: true,
                isDownloaded: false,
                downloadProgress: 0.0,
                error: ""
            )
        )
        if let destinationUrl = URL(string: downloadable.savePath) {
            print("dest url is \(destinationUrl)")
            if FileManager().fileExists(atPath: destinationUrl.path) {
                print("file already exists \(destinationUrl.path)")
                subject.send(
                    DownloadProgress(
                        id: downloadable.id,
                        isDownloading: false,
                        isDownloaded: true,
                        downloadProgress: 1.0,
                        error: ""
                    )
                )
                subject.send(completion: .finished)
            } else {
                print("run the download")
                let urlRequest = URLRequest(url: requestUrl)
                
                Metrics.shared.fileDownload(url: urlRequest.url)
                
                let downloadTask = urlSession.downloadTask(with: urlRequest)
                downloadTask.resume()
                urlToDownloadTask[requestUrl] = downloadTask
            }
        }
    }
    
    func cancel() {
        guard let requestUrl = downloadable.remoteLocation else {
            return
        }
        let task = urlToDownloadTask[requestUrl]
        task?.cancel()
        urlToDownloadTask.removeValue(forKey: requestUrl)
        urlToDownloadableMap.removeValue(forKey: requestUrl)
        subject.send(
            DownloadProgress(
                id: downloadable.id,
                isDownloading: false,
                isDownloaded: false,
                downloadProgress: 0.0,
                error: ""
            )
        )
        subject.send(completion: .finished)
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
    
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
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
            
            return (
                URLSession.AuthChallengeDisposition.useCredential,
                URLCredential(trust: challenge.protectionSpace.serverTrust!)
            )
        } catch {
            return (.cancelAuthenticationChallenge, nil)
        }
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        print("bytes downloaded \(totalBytesWritten)")
        subject.send(
            DownloadProgress(
                id: downloadable.id,
                isDownloading: true,
                isDownloaded: false,
                downloadProgress: Float(totalBytesWritten)/Float(totalBytesExpectedToWrite),
                error: ""
            )
        )
    }

    func saveError(downloadable: Downloadable, response: URLResponse?) {
        print("server error code \(response.debugDescription)")
        if let httpResponse = response as? HTTPURLResponse {
            subject.send(
                DownloadProgress(
                    id: downloadable.id,
                    isDownloading: false,
                    isDownloaded: false,
                    downloadProgress: 0.0,
                    error: "Error downloading (\(httpResponse.statusCode))"
                )
            )
        }
    }

    func prepareForSaving(destinationUrl: URL) {
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
            try FileManager.default.createDirectory(
                atPath: destinationUrl.deletingLastPathComponent().path,
                withIntermediateDirectories: true
            )
        } catch {
            print("error making dir \(error) \(destinationUrl.deletingLastPathComponent().path)")
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        urlSession.invalidateAndCancel()
        
        guard let url = downloadTask.currentRequest?.url, let downloadable = urlToDownloadableMap[url] else {
            subject.send(completion: .finished)
            return
        }
        
        urlToDownloadTask.removeValue(forKey: url)
        urlToDownloadableMap.removeValue(forKey: url)
        
        let destinationUrl: URL? = URL(string: downloadable.savePath)

        guard let destinationUrl = destinationUrl else {
            subject.send(completion: .finished)
            return
        }
        
        guard let httpResponse = downloadTask.response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            saveError(downloadable: downloadable, response: downloadTask.response)
            subject.send(completion: .finished)
            return
        }
        
        prepareForSaving(destinationUrl: destinationUrl)

        if !FileManager.default.fileExists(atPath: location.path) {
            print("error file not saved")
            subject.send(
                DownloadProgress(
                    id: downloadable.id,
                    isDownloading: false,
                    isDownloaded: false,
                    downloadProgress: 0.0,
                    error: "Error downloading (file not saved)"
                )
            )
            subject.send(completion: .finished)
            return
        }
        
        saveFile(location: location, destinationUrl: destinationUrl, downloadable: downloadable)
    }

    func saveFile(location: URL, destinationUrl: URL, downloadable: Downloadable) {
        do {
            try FileManager.default.moveItem(at: location, to: destinationUrl)
            let center = UNUserNotificationCenter.current()
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(
                forKey: "Download Complete",
                arguments: nil
            )
            content.body = NSString.localizedUserNotificationString(
                forKey: "Downloaded the file \(downloadable.title ?? "")",
                arguments: nil
            )
            content.sound = UNNotificationSound.default
            content.categoryIdentifier = "mil.nga.msi"
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2.0, repeats: false)
            let request = UNNotificationRequest.init(
                identifier: "downloadCompleted",
                content: content,
                trigger: trigger
            )

            // Schedule the notification.
            center.add(request)
            print("sending complete message")
            subject.send(
                DownloadProgress(
                    id: downloadable.id,
                    isDownloading: false,
                    isDownloaded: true,
                    downloadProgress: 1.0,
                    error: ""
                )
            )
            subject.send(completion: .finished)
        } catch {
            print("error saving file to \(destinationUrl.path) \(error)")
        }
    }
}

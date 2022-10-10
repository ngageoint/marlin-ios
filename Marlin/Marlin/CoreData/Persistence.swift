//
//  Persistence.swift
//  Shared
//
//  Created by Daniel Barela on 6/1/22.
//

import CoreData
import OSLog
import Combine

class PersistenceController {
    let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "persistence")
    
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let data: Data
        
        let filename = "asams.json"
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }
        
        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }
        
        do {
            let decoder = JSONDecoder()
            let asamContainer = try decoder.decode(AsamPropertyContainer.self, from: data)
            for asam in asamContainer.asam {
                let newItem = Asam(context: viewContext)
                newItem.asamDescription = asam.asamDescription
                newItem.longitude = asam.longitude
                newItem.latitude = asam.latitude
                newItem.date = asam.date
                newItem.navArea = asam.navArea
                newItem.reference = asam.reference
                newItem.subreg = asam.subreg
                newItem.position = asam.position
                newItem.hostility = asam.hostility
                newItem.victim = asam.victim
            }
        } catch {
            fatalError("Couldn't parse \(filename) as \(AsamPropertyContainer.self):\n\(error)")
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    private var notificationToken: NSObjectProtocol?
    
    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    var isLoaded: Bool = false

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Marlin")
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        print("Peristent store URL \(String(describing: description.url))")
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Enable persistent store remote change notifications
        /// - Tag: persistentStoreRemoteChange
        description.setOption(true as NSNumber,
                              forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        // Enable persistent history tracking
        /// - Tag: persistentHistoryTracking
        description.setOption(true as NSNumber,
                              forKey: NSPersistentHistoryTrackingKey)
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            self.isLoaded = true
            NotificationCenter.default.post(name: .PersistentStoreLoaded, object: nil)
            DispatchQueue.main.async {
                NSLog("Persistent store loaded, load all data")
                MSI.shared.loadAllData()
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.transactionAuthor = PersistenceController.authorName
        if !inMemory {
            do {
                try container.viewContext.setQueryGenerationFrom(.current)
            } catch {
                // log any errors
                NSLog("Errors setting query generation from \(error)")
            }
        }
        
        return container
    }()
    /// A peristent history token used for fetching transactions from the store.
    private var lastToken: NSPersistentHistoryToken?
    private var inMemory: Bool = false
    
    private lazy var historyRequestQueue = DispatchQueue(label: "history")
    var subscriptions = Set<AnyCancellable>()

    private init(inMemory: Bool = false) {
        self.inMemory = inMemory
        
        clearDataIfNecessary()
        NotificationCenter.default
            .publisher(for: .NSPersistentStoreRemoteChange)
            .sink { value in
                self.fetchPersistentHistoryTransactionsAndChanges()
            }
            .store(in: &subscriptions)
        
        // Observe Core Data remote change notifications on the queue where the changes were made.
        notificationToken = NotificationCenter.default.addObserver(forName: .NSPersistentStoreRemoteChange, object: nil, queue: nil) { note in
            self.logger.debug("Received a persistent store remote change notification.")
            self.fetchPersistentHistoryTransactionsAndChanges()
        }
        loadHistoryToken()
    }
    
    func clearDataIfNecessary() {
        // if the last time we loaded data was before the forceReloadDate, kill off the data and restart
        let forceReloadDate = UserDefaults.standard.forceReloadDate
        let lastLoadDate = UserDefaults.standard.lastLoadDate
        
        if let forceReloadDate = forceReloadDate, lastLoadDate < forceReloadDate {
            NSLog("Delete and reload")
            do
            {
                let storeURL: URL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Marlin.sqlite")
                try FileManager.default.removeItem(atPath: storeURL.path)
                let walURL: URL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Marlin.sqlite-wal")
                try FileManager.default.removeItem(atPath: walURL.path)
                let shmURL: URL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Marlin.sqlite-shm")
                try FileManager.default.removeItem(atPath: shmURL.path)
                let tokenURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("MSICoreDataToken", isDirectory: true)
                try FileManager.default.removeItem(atPath: tokenURL.path)
            }
            catch
            {
                print(error.localizedDescription)
            }
            
            for item in DataSourceList().allTabs {
                UserDefaults.standard.initialDataLoaded = false
                UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource)
            }
            UserDefaults.standard.lastLoadDate = Date()
        }
    }
    
    func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        /// - Tag: newBackgroundContext
        let taskContext = PersistenceController.shared.container.newBackgroundContext()
        taskContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        // Set unused undoManager to nil for macOS (it is nil by default on iOS)
        // to reduce resource requirements.
        taskContext.undoManager = nil
        return taskContext
    }
    
    private lazy var tokenFileURL: URL = {
        let url = NSPersistentContainer.defaultDirectoryURL()
            .appendingPathComponent("MSICoreDataToken", isDirectory: true)
        do {
            try FileManager.default
                .createDirectory(
                    at: url,
                    withIntermediateDirectories: true,
                    attributes: nil)
        } catch {
            // log any errors
        }
        return url.appendingPathComponent("token.data", isDirectory: false)
    }()
    
    private func storeHistoryToken(_ token: NSPersistentHistoryToken) {
        do {
            let data = try NSKeyedArchiver
                .archivedData(withRootObject: token, requiringSecureCoding: true)
            try data.write(to: tokenFileURL)
            lastToken = token
        } catch {
            // log any errors
        }
    }
    
    private func loadHistoryToken() {
        do {
            let tokenData = try Data(contentsOf: tokenFileURL)
            lastToken = try NSKeyedUnarchiver
                .unarchivedObject(ofClass: NSPersistentHistoryToken.self, from: tokenData)
        } catch {
            // log any errors
        }
    }
    
    private static let authorName = "MSI"
    private static let remoteDataImportAuthorName = "MSI Data Import"
    
    private func fetchPersistentHistoryTransactionsAndChanges() {
        historyRequestQueue.async { [self] in

            let taskContext = newTaskContext()
            taskContext.name = "persistentHistoryContext"
            logger.debug("Start fetching persistent history changes from the store...")
            
            try? taskContext.performAndWait { [self] in
                taskContext.transactionAuthor = PersistenceController.remoteDataImportAuthorName
                // Execute the persistent history change since the last transaction.
                /// - Tag: fetchHistory
                let changeRequest = NSPersistentHistoryChangeRequest.fetchHistory(after: self.lastToken)
                if let historyFetchRequest = NSPersistentHistoryTransaction.fetchRequest {
                    historyFetchRequest.predicate =
                    NSPredicate(format: "%K != %@", "author", PersistenceController.authorName)
                    changeRequest.fetchRequest = historyFetchRequest
                }
                let historyResult = try taskContext.execute(changeRequest) as? NSPersistentHistoryResult
                if let history = historyResult?.result as? [NSPersistentHistoryTransaction],
                   !history.isEmpty {
                    self.mergePersistentHistoryChanges(from: history)
                    return
                }
                
                self.logger.debug("No persistent history transactions found.")
                throw MSIError.persistentHistoryChangeError
            }
            
            logger.debug("Finished merging history changes.")
        }
    }
    
    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        self.logger.debug("Received \(history.count) persistent history transactions.")
        // Update view context with objectIDs from history change request.
        /// - Tag: mergeChanges
        let viewContext = container.viewContext
        viewContext.perform {
            for transaction in history {
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
                self.lastToken = transaction.token
            }
            
            if let newToken = history.last?.token {
                self.storeHistoryToken(newToken)
            }
        }
    }
}

//
//  Persistence.swift
//  Shared
//
//  Created by Daniel Barela on 6/1/22.
//

import CoreData
import OSLog
import Combine

protocol PersistentStore {
    func newTaskContext() -> NSManagedObjectContext
    func fetchFirst<T: NSManagedObject>(_ entityClass:T.Type,
                                                     sortBy: [NSSortDescriptor]?,
                                        predicate: NSPredicate?,
                                        context: NSManagedObjectContext?) throws-> T?
    func fetch<ResultType: NSFetchRequestResult>(fetchRequest: NSFetchRequest<ResultType>) throws -> [ResultType]
    func perform(_ block: @escaping () -> Void)
    func save() throws
    func fetchedResultsController<ResultType: NSFetchRequestResult>(fetchRequest: NSFetchRequest<ResultType>, sectionNameKeyPath: String?, cacheName name: String?) -> NSFetchedResultsController<ResultType>
    func addViewContextObserver(_ observer: AnyObject, selector: Selector, name: Notification.Name)
    func removeViewContextObserver(_ observer: AnyObject, name: Notification.Name)
    func countOfObjects<T: NSManagedObject>(_ entityClass:T.Type) throws -> Int?
    func mainQueueContext() -> NSManagedObjectContext
    func reset()
    
    var viewContext: NSManagedObjectContext { get }
}

class PersistenceController {
    fileprivate static let authorName = "MSI"
    fileprivate static let remoteDataImportAuthorName = "MSI Data Import"
    
    static var _current: PersistentStore?
    static var current: PersistentStore = {
        return _current ?? shared
    }()
    
    static var shared: PersistentStore = {
        _current = CoreDataPersistentStore()
        return _current!
    }()
    
    static var memory: PersistentStore = {
        _current = CoreDataPersistentStore(inMemory: true)
        return _current!
    }()
    
    static func mock(_ implementation: MockPersistentStore) -> PersistentStore {
        _current = implementation
        return _current!
    }
    
    static var mock: PersistentStore = {
        _current = MockPersistentStore()
        return _current!
    }()
}

class MockPersistentStore: PersistentStore {
    init() {
        
    }
    
    func newTaskContext() -> NSManagedObjectContext {
        return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }
    
    func fetchFirst<T: NSManagedObject>(_ entityClass:T.Type,
                                                     sortBy: [NSSortDescriptor]? = nil,
                                        predicate: NSPredicate? = nil,
                                        context: NSManagedObjectContext? = nil) throws-> T? {
        return nil
    }
    
    func perform(_ block: @escaping () -> Void) {
        
    }
    
    func save() throws {
        
    }
    
    func fetchedResultsController<ResultType: NSFetchRequestResult>(fetchRequest: NSFetchRequest<ResultType>, sectionNameKeyPath: String?, cacheName name: String?) -> NSFetchedResultsController<ResultType> {
        return NSFetchedResultsController<ResultType>(fetchRequest: fetchRequest,
                                                      managedObjectContext: newTaskContext(),
                                                      sectionNameKeyPath: sectionNameKeyPath,
                                                      cacheName: nil)
    }
    
    func fetch<ResultType: NSFetchRequestResult>(fetchRequest: NSFetchRequest<ResultType>) throws -> [ResultType] {
        return []
    }
    
    func addViewContextObserver(_ observer: AnyObject, selector: Selector, name: Notification.Name) {
        
    }
    
    func removeViewContextObserver(_ observer: AnyObject, name: Notification.Name) {
        
    }
    
    func countOfObjects<T: NSManagedObject>(_ entityClass:T.Type) throws -> Int? {
        return nil
    }
    
    func mainQueueContext() -> NSManagedObjectContext {
        return NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    }
    
    func reset() {
        
    }
    
    var viewContext: NSManagedObjectContext { self.mainQueueContext() }
}

class CoreDataPersistentStore: PersistentStore {
    let logger = Logger(subsystem: "mil.nga.msi.Marlin", category: "persistence")
    
    func fetchFirst<T: NSManagedObject>(_ entityClass:T.Type,
                                                     sortBy: [NSSortDescriptor]? = nil,
                                                     predicate: NSPredicate? = nil,
                                        context: NSManagedObjectContext? = nil) throws-> T? {
        
        return try (context ?? container.viewContext).fetchFirst(entityClass, sortBy: sortBy, predicate: predicate)
    }
    
    func fetch<ResultType: NSFetchRequestResult>(fetchRequest: NSFetchRequest<ResultType>) throws -> [ResultType] {
        return try container.viewContext.fetch(fetchRequest)
    }
    
    func perform(_ block: @escaping () -> Void) {
        container.viewContext.perform(block)
    }
    
    func save() throws {
        try container.viewContext.save()
    }
    
    func fetchedResultsController<ResultType: NSFetchRequestResult>(fetchRequest: NSFetchRequest<ResultType>, sectionNameKeyPath: String?, cacheName name: String?) -> NSFetchedResultsController<ResultType> {
        return NSFetchedResultsController<ResultType>(fetchRequest: fetchRequest,
                                                                managedObjectContext: container.viewContext,
                                                                sectionNameKeyPath: sectionNameKeyPath,
                                                                cacheName: nil)
    }
    
    func addViewContextObserver(_ observer: AnyObject, selector: Selector, name: Notification.Name) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: container.viewContext)
    }
    
    func removeViewContextObserver(_ observer: AnyObject, name: Notification.Name) {
        NotificationCenter.default.removeObserver(observer, name: name, object: container.viewContext)
    }
    
    func countOfObjects<T: NSManagedObject>(_ entityClass:T.Type) throws -> Int? {
        var count: Int?
        container.viewContext.performAndWait {
            count = try? container.viewContext.countOfObjects(entityClass)
        }
        return count
    }
    
    func mainQueueContext() -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.automaticallyMergesChangesFromParent = false
        context.parent = container.viewContext
        return context
    }
    
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    private var notificationToken: NSObjectProtocol?
    
    deinit {
        if let observer = notificationToken {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    var isLoaded: Bool = false
    
    private var _container: NSPersistentContainer?
        
    static var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: PersistenceController.self)
        
        guard let url = bundle.url(forResource: "Marlin", withExtension: "momd") else {
            fatalError("Failed to locate momd file for xcdatamodeld")
        }
                
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load momd file for xcdatamodeld")
        }
        
        return model
    }()

    var container : NSPersistentContainer {
        if(_container == nil) {
            _container = initializeContainer()
        }
        return _container!
    }
    
    func reset() {
        do {
            let tokenURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("MSICoreDataToken", isDirectory: true)
            try FileManager.default.removeItem(atPath: tokenURL.path)
        } catch {
            print(error.localizedDescription)
        }
        lastToken = nil
        do {
            let currentStore = _container?.persistentStoreCoordinator.persistentStores.last!
            if let currentStoreURL = currentStore?.url {
                print("Current store url \(currentStoreURL)")
                try _container?.persistentStoreCoordinator.destroyPersistentStore(at: currentStoreURL, type: .sqlite)

            }
        } catch {
            print("Exception destroying \(error)")
        }
        _container = nil
        isLoaded = false
        _container = container
    }
    
    func initializeContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: "Marlin", managedObjectModel: CoreDataPersistentStore.managedObjectModel)
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        print("Peristent store URL \(String(describing: description.url))")
        if inMemory {
            description.url = URL(fileURLWithPath: "/dev/null")
            print("in memory")
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
            print("Persistent store was loaded sending notification")
            
            NotificationCenter.default.post(name: .PersistentStoreLoaded, object: nil)
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
    }

    /// A peristent history token used for fetching transactions from the store.
    private var lastToken: NSPersistentHistoryToken?
    private var inMemory: Bool = false
    
    private lazy var historyRequestQueue = DispatchQueue(label: "history")
    var subscriptions = Set<AnyCancellable>()

    fileprivate init(inMemory: Bool = false) {
        self.inMemory = inMemory
        
        clearDataIfNecessary()
        _container = initializeContainer()
        NotificationCenter.default
            .publisher(for: .NSPersistentStoreRemoteChange)
            .sink { value in
                self.fetchPersistentHistoryTransactionsAndChanges()
            }
            .store(in: &subscriptions)
        
        loadHistoryToken()
    }
    
    func clearDataIfNecessary() {
        // if the last time we loaded data was before the forceReloadDate, kill off the data and restart
        let forceReloadDate = UserDefaults.standard.forceReloadDate
        let lastLoadDate = UserDefaults.standard.lastLoadDate
        
        if let forceReloadDate = forceReloadDate, lastLoadDate < forceReloadDate, !inMemory {
            NSLog("Delete and reload")
            if !inMemory {
                do
                {
                    let storeURL: URL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Marlin.sqlite")
                    try FileManager.default.removeItem(atPath: storeURL.path)
                    let walURL: URL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Marlin.sqlite-wal")
                    try FileManager.default.removeItem(atPath: walURL.path)
                    let shmURL: URL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Marlin.sqlite-shm")
                    try FileManager.default.removeItem(atPath: shmURL.path)
                }
                catch
                {
                    print(error.localizedDescription)
                }
            }
            do {
                let tokenURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("MSICoreDataToken", isDirectory: true)
                try FileManager.default.removeItem(atPath: tokenURL.path)
            } catch {
                print(error.localizedDescription)
            }
            
            for item in DataSourceList().allTabs {
                UserDefaults.standard.initialDataLoaded = false
                UserDefaults.standard.clearLastSyncTimeSeconds(item.dataSource.definition)
            }
            UserDefaults.standard.lastLoadDate = Date()
        }
    }
    
    func newTaskContext() -> NSManagedObjectContext {
        // Create a private queue context.
        /// - Tag: newBackgroundContext
        let taskContext = container.newBackgroundContext()
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
    
    private func fetchPersistentHistoryTransactionsAndChanges() {
        logger.info("Told to fetch persistent history transactions and changes")
        historyRequestQueue.async { [self] in

            let taskContext = newTaskContext()
            taskContext.name = "persistentHistoryContext"
            logger.info("Start fetching persistent history changes from the store...")
            
            try? taskContext.performAndWait { [self] in
                do {
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
                } catch {
                    self.logger.info("Error \(error)")
                }
                
                self.logger.info("No persistent history transactions found.")
                throw MSIError.persistentHistoryChangeError
            }
            
            logger.info("Finished merging history changes.")
        }
    }
    
    private func mergePersistentHistoryChanges(from history: [NSPersistentHistoryTransaction]) {
        let entityMap: [String? : String] = [
            Asam.entity().name : DataSources.asam.key,
            DFRS.entity().name : DataSources.dfrs.key,
            DifferentialGPSStation.entity().name : DataSources.dgps.key,
            ElectronicPublication.entity().name : DataSources.epub.key,
            Light.entity().name : DataSources.light.key,
            Modu.entity().name : DataSources.modu.key,
            NavigationalWarning.entity().name : DataSources.navWarning.key,
            NoticeToMariners.entity().name : DataSources.noticeToMariners.key,
            Port.entity().name : DataSources.port.key,
            RadioBeacon.entity().name : DataSources.radioBeacon.key
        ]

        self.logger.info("Received \(history.count) persistent history transactions.")
        if let newToken = history.last?.token {
            self.lastToken = newToken
            self.storeHistoryToken(newToken)
        }
        // Update view context with objectIDs from history change request.
        /// - Tag: mergeChanges
        let viewContext = container.viewContext
        viewContext.perform {
            var updateCounts: [String? : Int] = [:]
            var insertCounts: [String? : Int] = [:]
            for transaction in history {
                NSLog("Transaction author \(transaction.author ?? "No author")")
                let notif = transaction.objectIDNotification()
                let inserts: Set<NSManagedObjectID> = notif.userInfo?["inserted_objectIDs"] as? Set<NSManagedObjectID> ?? Set<NSManagedObjectID>()
                let updates: Set<NSManagedObjectID> = notif.userInfo?["updated_objectIDs"] as? Set<NSManagedObjectID> ?? Set<NSManagedObjectID>()
                
                for insert in inserts {
                    let entityKey = entityMap[insert.entity.name]
                    insertCounts[entityKey] = (insertCounts[entityKey] ?? 0) + 1
                }
                for update in updates {
                    let entityKey = entityMap[update.entity.name]
                    updateCounts[entityKey] = (updateCounts[entityKey] ?? 0) + 1
                }
                viewContext.mergeChanges(fromContextDidSave: transaction.objectIDNotification())
            }
            
            var dataSourceUpdatedNotifications: [DataSourceUpdatedNotification] = []
            for dataSource in MSI.shared.masterDataList {
                let inserts = insertCounts[dataSource.key] ?? 0
                let updates = updateCounts[dataSource.key] ?? 0
                if inserts != 0 || updates != 0 {
                    dataSourceUpdatedNotifications.append(DataSourceUpdatedNotification(key: dataSource.key, updates: updates, inserts: inserts))
                }
            }
            
            NotificationCenter.default.post(Notification(name: .BatchUpdateComplete, object: BatchUpdateComplete(dataSourceUpdates: dataSourceUpdatedNotifications)))
        }
    }
    
    static var preview: PersistentStore = {
        let result = CoreDataPersistentStore(inMemory: true)
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
    
}

//
//  BookmarkLocalDataSource.swift
//  Marlin
//
//  Created by Daniel Barela on 3/4/24.
//

import Foundation
import CoreData
import Combine
import UIKit
import BackgroundTasks

private struct BookmarkLocalDataSourceProviderKey: InjectionKey {
    static var currentValue: BookmarkLocalDataSource = BookmarkCoreDataDataSource()
}

extension InjectedValues {
    var bookmarkLocalDataSource: BookmarkLocalDataSource {
        get { Self[BookmarkLocalDataSourceProviderKey.self] }
        set { Self[BookmarkLocalDataSourceProviderKey.self] = newValue }
    }
}

protocol BookmarkLocalDataSource {
    func getBookmark(itemKey: String, dataSource: String) -> BookmarkModel?
    func createBookmark(notes: String?, itemKey: String, dataSource: String) async
    func removeBookmark(itemKey: String, dataSource: String) -> Bool
    func bookmarks(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<[BookmarkItem], Error>
}

struct BookmarkModelPage {
    var list: [BookmarkItem]
    var next: Int?
    var currentHeader: String?
}

class BookmarkCoreDataDataSource: CoreDataDataSource, BookmarkLocalDataSource {
    func getBookmark(itemKey: String, dataSource: String) -> BookmarkModel? {
        let context = PersistenceController.current.viewContext
        return context.performAndWait {
            if let bookmark = try? context.fetchFirst(
                Bookmark.self,
                predicate: NSPredicate(format: "id == %@ AND dataSource == %@", itemKey, dataSource)) {
                return BookmarkModel(bookmark: bookmark)
            }
            return nil
        }
    }

    func createBookmark(notes: String?, itemKey: String, dataSource: String) async {
        let context = PersistenceController.current.viewContext
        await context.perform {
            let bookmark = Bookmark(context: context)
            bookmark.notes = notes
            bookmark.dataSource = dataSource
            bookmark.id = itemKey
            bookmark.timestamp = Date()
            do {
                try context.save()
            } catch {
                print("Error saving bookmark \(error)")
            }
        }
    }

    func removeBookmark(itemKey: String, dataSource: String) -> Bool {
        let context = PersistenceController.current.viewContext
        return context.performAndWait {
            let request = Bookmark.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@ AND dataSource = %@", itemKey, dataSource)
            for bookmark in context.fetch(request: request) ?? [] {
                context.delete(bookmark)
            }
            do {
                try context.save()
                return true
            } catch {
                print("Error removing bookmark")
            }
            return false
        }
    }
}

// MARK: Data Publisher methods
extension BookmarkCoreDataDataSource {

    func bookmarks(
        filters: [DataSourceFilterParameter]?,
        paginatedBy paginator: Trigger.Signal? = nil
    ) -> AnyPublisher<[BookmarkItem], Error> {
        return bookmarks(filters: filters, at: nil, currentHeader: nil, paginatedBy: paginator)
            .map(\.list)
            .eraseToAnyPublisher()
    }

    func bookmarks(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?
    ) -> AnyPublisher<BookmarkModelPage, Error> {

        let context = PersistenceController.current.newTaskContext()
        let request = Bookmark.fetchRequest()
        let predicates: [NSPredicate] = buildPredicates(filters: filters)
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.predicate = predicate

        request.fetchLimit = 100
        request.fetchOffset = (page ?? 0) * request.fetchLimit
        let userSort = UserDefaults.standard.sort(DataSources.bookmark.key)
        let sortDescriptors: [DataSourceSortParameter] =
        userSort.isEmpty ? DataSources.bookmark.defaultSort : userSort

        request.sortDescriptors = sortDescriptors.toNSSortDescriptors()
        var previousHeader: String? = currentHeader
        var bookmarks: [BookmarkItem] = []
        context.performAndWait {
            if let fetched = context.fetch(request: request) {

                bookmarks = fetched.flatMap { bookmark in
                    guard let sortDescriptor = sortDescriptors.first else {
                        return [BookmarkItem.listItem(BookmarkModel(bookmark: bookmark))]
                    }

                    if !sortDescriptor.section {
                        return [BookmarkItem.listItem(BookmarkModel(bookmark: bookmark))]
                    }

                    return createSectionHeaderAndListItem(
                        bookmark: bookmark,
                        sortDescriptor: sortDescriptor,
                        previousHeader: &previousHeader
                    )
                }
            }
        }

        let bookmarkPage: BookmarkModelPage = BookmarkModelPage(
            list: bookmarks,
            next: (page ?? 0) + 1,
            currentHeader: previousHeader
        )

        return Just(bookmarkPage)
            .setFailureType(to: Error.self)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func createSectionHeaderAndListItem(
        bookmark: Bookmark,
        sortDescriptor: DataSourceSortParameter,
        previousHeader: inout String?
    ) -> [BookmarkItem] {
        let currentValue = bookmark.value(forKey: sortDescriptor.property.key)
        let sortValueString: String? = getCurrentSortValue(sortDescriptor: sortDescriptor, sortValue: currentValue)

        if let previous = previousHeader, let sortValueString = sortValueString {
            if previous != sortValueString {
                previousHeader = sortValueString
                return [
                    BookmarkItem.sectionHeader(header: sortValueString),
                    BookmarkItem.listItem(BookmarkModel(bookmark: bookmark))
                ]
            }
        } else if previousHeader == nil, let sortValueString = sortValueString {
            previousHeader = sortValueString
            return [
                BookmarkItem.sectionHeader(header: sortValueString),
                BookmarkItem.listItem(BookmarkModel(bookmark: bookmark))
            ]
        }

        return [BookmarkItem.listItem(BookmarkModel(bookmark: bookmark))]
    }

    func getCurrentSortValue(sortDescriptor: DataSourceSortParameter, sortValue: Any?) -> String? {
        var sortValueString: String?
        switch sortDescriptor.property.type {
        case .string:
            sortValueString = sortValue as? String
        case .date:
            if let currentValue = sortValue as? Date {
                sortValueString = DataSources.bookmark.dateFormatter.string(from: currentValue)
            }
        case .int:
            sortValueString = (sortValue as? Int)?.zeroIsEmptyString
        case .float:
            sortValueString = (sortValue as? Float)?.zeroIsEmptyString
        case .double:
            sortValueString = (sortValue as? Double)?.zeroIsEmptyString
        case .boolean:
            sortValueString = ((sortValue as? Bool) ?? false) ? "True" : "False"
        case .enumeration:
            sortValueString = sortValue as? String
        case .latitude:
            sortValueString = (sortValue as? Double)?.latitudeDisplay
        case .longitude:
            sortValueString = (sortValue as? Double)?.longitudeDisplay
        default:
            return nil
        }
        return sortValueString
    }

    func bookmarks(
        filters: [DataSourceFilterParameter]?,
        at page: Page?,
        currentHeader: String?,
        paginatedBy paginator: Trigger.Signal?
    ) -> AnyPublisher<BookmarkModelPage, Error> {
        return bookmarks(filters: filters, at: page, currentHeader: currentHeader)
            .map { result -> AnyPublisher<BookmarkModelPage, Error> in
                if let paginator = paginator, let next = result.next {
                    return self.bookmarks(
                        filters: filters,
                        at: next,
                        currentHeader: result.currentHeader,
                        paginatedBy: paginator
                    )
                    .wait(untilOutputFrom: paginator)
                    .retry(.max)
                    .prepend(result)
                    .eraseToAnyPublisher()
                } else {
                    return Just(result)
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

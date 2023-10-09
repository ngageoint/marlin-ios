//
//  PublisherExtensions.swift
//  Marlin
//
//  Created by Daniel Barela on 10/5/23.
//

import Foundation
import Combine

extension Publisher {
    func applyingChanges<Changes: Publisher, ChangeItem>(
        _ changes: Changes,
        _ transform: @escaping (ChangeItem) -> Output.Element
    ) -> AnyPublisher<Output, Failure>
    where Output: RangeReplaceableCollection,
          Output.Index == Int,
          Changes.Output == CollectionDifference<ChangeItem>,
          Changes.Failure == Failure
    {
        zip(changes) { existing, changes -> Output in
            var objects = existing
            for change in changes {
                switch change {
                case .remove(let offset, _, _):
                    objects.remove(at: offset)
                case .insert(let offset, let obj, _):
                    let transformed = transform(obj)
                    objects.insert(transformed, at: offset)
                }
            }
            return objects
        }.eraseToAnyPublisher()
    }
}

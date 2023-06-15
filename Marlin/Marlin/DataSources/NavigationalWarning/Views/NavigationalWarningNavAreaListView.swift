//
//  NavigationalWarningNavAreaListView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/24/22.
//

import SwiftUI
import Combine

struct NavigationalWarningNavAreaListView: View {
    @AppStorage<String> var lastSeen: String
    @State var lastSavedDate: Date = Date(timeIntervalSince1970: 0)
    @State var scrollingTo: ObjectIdentifier?
    @State var shouldSavePosition: Bool = false
    
    @State var firstUnseenNavigationalWarning: NavigationalWarning?
    @State var tappedItem: NavigationalWarning?
    @State private var showDetail = false

    @StateObject var scrollViewHelper = ScrollViewHelper()
    
    @StateObject var dataSource = NavigationalWarningsAreaDataSource()
    var mapName: String?
    var navArea: String
    var warnings: [NavigationalWarning]
    init(warnings: [NavigationalWarning], navArea: String, mapName: String?) {
        self.warnings = warnings
        self.navArea = navArea
        self._lastSeen = AppStorage(wrappedValue: "", "lastSeen-\(navArea)")
        self.mapName = mapName
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack (alignment: .leading) {
                    NavigationLink(destination: AnyView(tappedItem?.detailView), isActive: self.$showDetail) {
                        EmptyView()
                    }.hidden()
                    ForEach(dataSource.items) { navigationalWarning in
                        ZStack {
                            NavigationLink {
                                navigationalWarning.detailView
                            } label: {
                                HStack {
                                    navigationalWarning.summaryView(mapName: mapName)
                                        .padding(.all, 16)
                                }
                                .card()
                                .background(GeometryReader {
                                    return Color.clear.preference(key: ViewOffsetKey.self,
                                                                  value: -$0.frame(in: .named("scroll")).origin.y)
                                })
                                
                                .onPreferenceChange(ViewOffsetKey.self) { offset in
                                    if offset > 0 {
                                        firstUnseenNavigationalWarning = navigationalWarning
                                    }
                                    // once this offset goes negative, they have seen the nav warning
                                    if offset < 0 {
                                        // This checks if we are saving right now, because we could be still scrolling to the bottom
                                        // also checks if we have already saved a newer warning as the latest one
                                        if shouldSavePosition, let issueDate = navigationalWarning.issueDate, issueDate > lastSavedDate {
                                            self.lastSavedDate = issueDate
                                            self.lastSeen = navigationalWarning.primaryKey
                                        }
                                    }
                                }
                            }
                        }
                            .onTapGesture {
                                tappedItem = navigationalWarning
                                showDetail.toggle()
                            }
                            .accessibilityElement(children: .contain)
                            .accessibilityLabel("\(navigationalWarning.itemTitle) summary")
//                        }
//                        .accessibilityElement(children: .contain)
//                        .accessibilityLabel(navigationalWarning.primaryKey)
                    }
                    .padding(.all, 8)
                }.background(GeometryReader {
                    return Color.clear.preference(key: ViewOffsetKey.self,
                                                  value: -$0.frame(in: .named("scroll")).origin.y)
                })
                .onPreferenceChange(ViewOffsetKey.self) {
                    scrollViewHelper.currentOffset = $0
                }.onReceive(scrollViewHelper.$offsetAtScrollEnd) {
                    if $0 != 0 {
                        // find the one that is one older than the first unseen and save that, also turn on auto saving
                        shouldSavePosition = true
                        if let firstUnseenNavigationalWarning = firstUnseenNavigationalWarning, let lastSeenNavigationalWarning = dataSource.items.item(after: firstUnseenNavigationalWarning) {
                            if let issueDate = lastSeenNavigationalWarning.issueDate, lastSavedDate < issueDate {
                                self.lastSavedDate = issueDate
                                self.lastSeen = lastSeenNavigationalWarning.primaryKey
                            }
                        }
                    }
                }
                .onAppear {
                    dataSource.setNavigationalWarnings(areaWarnings: warnings)
                }
                .onChange(of: dataSource.items.count) { newValue in
                    let lastSeenNavWarning = dataSource.items.first { warning in
                        warning.primaryKey == lastSeen
                    }
                    if let lastSeenNavWarning = lastSeenNavWarning {
                        scrollingTo = lastSeenNavWarning.id
                        proxy.scrollTo(lastSeenNavWarning.id, anchor: .top)
                    } else {
                        // haven't seen any, scroll to the bottom
                        if let lastId = dataSource.items.last?.id {
                            scrollingTo = lastId
                            proxy.scrollTo(lastId)
                        }
                    }
                }
            }
            .safeAreaInset(edge: .top) {
                if lastSavedDate != dataSource.items.first?.issueDate {
                    if let lastSeenIndex = dataSource.items.firstIndex(where: { warning in
                        warning.primaryKey == lastSeen
                    }) {
                        let unreadCount = dataSource.items.distance(from: dataSource.items.startIndex, to: lastSeenIndex)
                        if unreadCount != 0 {
                            Text("\(unreadCount) Unread Warnings")
                                .modifier(UnreadModifier())
                                .onTapGesture {
                                    DispatchQueue.main.async {
                                        withAnimation(Animation.easeInOut(duration: 1).delay(1)) {
                                            if let firstId = dataSource.items.first?.id {
                                                scrollingTo = firstId
                                                proxy.scrollTo(firstId)
                                            }
                                        }
                                    }
                                }
                        }
                    } else {
                        Text("\(dataSource.items.count) Unread Warnings")
                            .modifier(UnreadModifier())
                            .onTapGesture {
                                DispatchQueue.main.async {
                                    withAnimation(Animation.easeInOut(duration: 1).delay(1)) {
                                        if let firstId = dataSource.items.first?.id {
                                            scrollingTo = firstId
                                            proxy.scrollTo(firstId)
                                        }
                                    }
                                }
                            }
                    }
                }
            }
            .background(Color.backgroundColor)
            .coordinateSpace(name: "scroll")
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("Navigation Warning Scroll")
        }
        .onAppear {
            Metrics.shared.appRoute([NavigationalWarning.metricsKey, "list"])
            shouldSavePosition = false
        }
        .navigationTitle(NavigationalWarningNavArea.fromId(id: navArea)?.display ?? "Navigational Warnings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension Collection where Iterator.Element: Equatable {
    typealias Element = Self.Iterator.Element

    func safeIndex(after index: Index) -> Index? {
        let nextIndex = self.index(after: index)
        return (nextIndex < self.endIndex) ? nextIndex : nil
    }

    func index(afterWithWrapAround index: Index) -> Index {
        return self.safeIndex(after: index) ?? self.startIndex
    }

    func item(after item: Element) -> Element? {
        return self.firstIndex(of: item)
            .flatMap(self.safeIndex(after:))
            .map{ self[$0] }
    }

    func item(afterWithWrapAround item: Element) -> Element? {
        return self.firstIndex(of: item)
            .map(self.index(afterWithWrapAround:))
            .map{ self[$0] }
    }
}

class ScrollViewHelper: ObservableObject {
    
    @Published var currentOffset: CGFloat = 0
    @Published var offsetAtScrollEnd: CGFloat = 0
    
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = AnyCancellable($currentOffset
            .throttle(for: 0.2, scheduler: DispatchQueue.main, latest: true)
            .dropFirst()
            .assign(to: \.offsetAtScrollEnd, on: self))
    }
    
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

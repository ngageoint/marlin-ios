//
//  TabView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/13/22.
//

import SwiftUI

class ItemWrapper : ObservableObject {
    @Published var asam: Asam?
}

struct MarlinTabView: View {
    
    var viewAsamNotificationObserver: Any?

    @EnvironmentObject var scheme: MarlinScheme
    
    @StateObject var itemWrapper: ItemWrapper
    @State var selection: String? = nil
    
    let pub = NotificationCenter.default.publisher(for: .ViewAsam)
    
    var body: some View {
        TabView {
            AsamListView()
                .tabItem {
                    Label("ASAMs", image: "asam")
                }
            
            NavigationView {
                VStack {
                    NavigationLink(tag: "asam", selection: $selection) {
                        if let asam = itemWrapper.asam {
                            AsamDetailView(asam: asam)
                        } else {
                            EmptyView()
                        }
                    } label: {
                        EmptyView()
                    }.hidden()
                MarlinMap()
                    .navigationTitle("Marlin")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem (placement: .navigation)  {
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(Color(scheme.containerScheme.colorScheme.onPrimaryColor))
                                .onTapGesture {
                                    self.showHamburger()
                                }
                        }
                    }
                }
            }.tabItem {
                Label("Map", systemImage: "map.fill")
            }
            // this affects text buttons, image buttons need .foregroundColor set on them
            .tint(Color(scheme.containerScheme.colorScheme.onPrimaryColor))
            .navigationViewStyle(.stack)
            .statusBar(hidden: false)
            

        }
        .onReceive(pub) { output in
            print("view asam recieved \(output)")
            viewAsam(output.object as! Asam)
        }
//        .accentColor(Color(scheme.containerScheme.colorScheme.primaryColorVariant))
    }
    
    func viewAsam(_ asam: Asam) {
        NotificationCenter.default.post(name: .MapAnnotationFocused, object: nil)
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.asam = asam
        selection = "asam"
//        let ovc = ObservationViewCardCollectionViewController(observation: observation, scheme: scheme)
//        navigationController?.pushViewController(ovc, animated: true)
    }
    
    private func showHamburger() {
    }
}

struct MarlinTabView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MarlinTabView(itemWrapper: ItemWrapper()).environmentObject(MarlinScheme.init()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

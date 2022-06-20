//
//  TabView.swift
//  Marlin
//
//  Created by Daniel Barela on 6/13/22.
//

import SwiftUI

class ItemWrapper : ObservableObject {
    @Published var asam: Asam?
    @Published var modu: Modu?
}

struct MarlinTabView: View {
    
    @EnvironmentObject var scheme: MarlinScheme
    
    @StateObject var itemWrapper: ItemWrapper
    @State var selection: String? = nil
    
    let asamPub = NotificationCenter.default.publisher(for: .ViewAsam)
    let moduPub = NotificationCenter.default.publisher(for: .ViewModu)
    
    var body: some View {
        TabView {
            ModuListView()
                .tabItem {
                    Label("MODUs", image: "modu")
                }
            
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
                    NavigationLink(tag: "modu", selection: $selection) {
                        if let modu = itemWrapper.modu {
                            ModuDetailView(modu: modu)
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
        .onReceive(asamPub) { output in
            print("view asam recieved \(output)")
            viewAsam(output.object as! Asam)
        }
        .onReceive(moduPub) { output in
            print("view modu recieved \(output)")
            viewModu(output.object as! Modu)
        }
//        .accentColor(Color(scheme.containerScheme.colorScheme.primaryColorVariant))
    }
    
    func viewAsam(_ asam: Asam) {
        NotificationCenter.default.post(name: .MapAnnotationFocused, object: nil)
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.asam = asam
        selection = "asam"
    }
    
    func viewModu(_ modu: Modu) {
        NotificationCenter.default.post(name: .MapAnnotationFocused, object: nil)
        NotificationCenter.default.post(name:.DismissBottomSheet, object: nil)
        itemWrapper.modu = modu
        selection = "modu"
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

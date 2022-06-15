//
//  AsamBottomSheet.swift
//  Marlin
//
//  Created by Daniel Barela on 6/14/22.
//

import SwiftUI

struct AsamBottomSheet: View {
    
    @ObservedObject var asam: Asam
    
    var body: some View {
        VStack {
            Text(asam.navArea!)
            Text(asam.asamDescription!).lineLimit(5)
        }
    }
}

struct AsamBottomSheet_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let asam = try? context.fetchFirst(Asam.self)
        return AsamBottomSheet(asam: asam!)
    }
}

//
//  EventuraApp.swift
//  Eventura
//
//  Created by Mac DEKHAIL on 21/02/2025.
//

import SwiftUI

@main
struct EventuraApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

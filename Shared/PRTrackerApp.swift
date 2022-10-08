//
//  PRTrackerApp.swift
//  Shared
//
//  Created by Brevin Blalock on 5/19/22.
//

import SwiftUI

@main
struct PRTrackerApp: App {
    
    @AppStorage("initialWorkoutSet") private var initialWorkoutSet: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
        }
    }
}

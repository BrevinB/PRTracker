//
//  PRTrackerApp.swift
//  Shared
//
//  Created by Brevin Blalock on 5/19/22.
//

import SwiftUI
import RevenueCat

@main
struct PRTrackerApp: App {
    
    @AppStorage("initialWorkoutSet") private var initialWorkoutSet: Bool = false
    @AppStorage("isImperial") private var isImperial: Bool = true
    @StateObject var healthViewModel = HealthKitViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
                .environmentObject(healthViewModel)
        }
    }
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_yhjPcPtPaIzsgSrkfvGGkjBTfmT")
    }
}

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
    let hkManager = HealthKitManager()
    let userManager = UserManager()
    let weightVM = WeightViewModel()
    let workoutVM = WorkoutViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, CoreDataManager.shared.viewContext)
                .environment(hkManager)
                .environment(userManager)
                .environment(weightVM)
                .environment(workoutVM)
        }
    }
}

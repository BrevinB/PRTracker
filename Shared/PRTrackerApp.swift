//
//  PRTrackerApp.swift
//  Shared
//
//  Created by Brevin Blalock on 5/19/22.
//

import SwiftUI
import RevenueCat
import StoreKit

@main
struct PRTrackerApp: App {
    
    @AppStorage("initialWorkoutSet") private var initialWorkoutSet: Bool = false
    @AppStorage("isImperial") private var isImperial: Bool = true
    @AppStorage("launchCount") private var launchCount: Int = 0
    @AppStorage("lastVersion") private var lastVersion: String = ""
    
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
                .onAppear {
                    incrementLaunchCount()
                }
        }
    }
    
    private func incrementLaunchCount() {
        if let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            print("Launch Count Current Version \(currentVersion)")
            print("Launch Count Last Version \(lastVersion)")
            // Check if the version has changed
            if currentVersion != lastVersion {
                // Reset launch count and update the stored version
                launchCount = 0
                lastVersion = currentVersion
            }
        }
        
        launchCount += 1
        print("Launch Count \(launchCount)")
        if launchCount == 5 {
            print(launchCount)
            requestReview()
        }
    }
    
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }
}

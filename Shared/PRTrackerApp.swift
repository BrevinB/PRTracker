//
//  PRTrackerApp.swift
//  Shared
//
//  Created by Brevin Blalock on 5/19/22.
//

import SwiftUI
import RevenueCat
import StoreKit
import WishKit

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
    
    init() {
        WishKit.configure(with: "API KEY")
    }
    
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
            // Check if the version has changed
            if currentVersion != lastVersion {
                // Reset launch count and update the stored version
                launchCount = 0
                lastVersion = currentVersion
            }
        }
        
        launchCount += 1
        
        if launchCount == 5 {
            requestReview()
        }
    }
    
    private func requestReview() {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
    }
}

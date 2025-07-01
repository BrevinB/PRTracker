//
//  ContentView.swift
//  Shared
//
//  Created by Brevin Blalock on 5/19/22.
//

import SwiftUI
import HealthKit

struct ContentView: View {
   
    @Environment(\.managedObjectContext) var moc
    @Environment(HealthKitManager.self) private var hkManager
    @Environment(WorkoutViewModel.self) private var workoutVM
    @Environment(WeightViewModel.self) private var weightVM
    @AppStorage("initialWorkoutSet") private var initialWorkoutSet: Bool = false
    @AppStorage("isHealthKitAuthorized") private var authorizeHealthkit: Bool = false
    
    var body: some View {
        VStack {
            if authorizeHealthkit {
                if initialWorkoutSet {
                    Home(moc: moc)
                } else {
                    OnboardingView()
                }
            } else {
                
            }
        }
        .onAppear {
            if !authorizeHealthkit {
                hkManager.healthRequest()
                authorizeHealthkit = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

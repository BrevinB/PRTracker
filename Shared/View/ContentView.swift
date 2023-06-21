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
    @EnvironmentObject var HealthVM: HealthKitViewModel
    @StateObject private var WorkoutVM = WorkoutViewModel()
    @AppStorage("initialWorkoutSet") private var initialWorkoutSet: Bool = false
    @AppStorage("isHealthKitAuthorized") private var authorizeHealthkit: Bool = false
    
    
    var body: some View {
        VStack {
            if authorizeHealthkit {
                if initialWorkoutSet {
                    Home(moc: moc)
                }
            } else {
                
            }
        }
        .onAppear {
            if !initialWorkoutSet {
                WorkoutVM.type = "Body Weight"
                WorkoutVM.save()
                WorkoutVM.type = "Squat"
                WorkoutVM.save()
                WorkoutVM.type = "Bench"
                WorkoutVM.save()
                WorkoutVM.type = "Deadlift"
                WorkoutVM.save()
                initialWorkoutSet = true
            }
            
            if !authorizeHealthkit {
                HealthVM.healthRequest()
                authorizeHealthkit = true
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

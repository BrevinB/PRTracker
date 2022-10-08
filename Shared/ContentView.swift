//
//  ContentView.swift
//  Shared
//
//  Created by Brevin Blalock on 5/19/22.
//

import SwiftUI

struct ContentView: View {
   
    @Environment(\.managedObjectContext) var moc
    @StateObject private var WorkoutVM = WorkoutViewModel()
    @AppStorage("initialWorkoutSet") private var initialWorkoutSet: Bool = false
    
    
    var body: some View {
        
        
        VStack {
            
            if initialWorkoutSet {
                Home(moc: moc)
            } else {
                Text("Hi")
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
        }
    }
    
    func test() {
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

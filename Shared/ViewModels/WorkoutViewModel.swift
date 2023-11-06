//
//  WorkoutViewModel.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 9/15/22.
//

import Foundation
import CoreData

class WorkoutViewModel: ObservableObject {
    
    @Published var workouts = [WorkoutModel]()
    
    func deleteWorkout(workout: WorkoutModel) {
        let workout = CoreDataManager.shared.getWorkoutById(id: workout.typeId)
        
        if let workout = workout {
            CoreDataManager.shared.deleteWorkout(workout)
        }
        
        CoreDataManager.shared.save()
    }
    
    func getAllWorkouts() {
        let workouts = CoreDataManager.shared.getAllWorkouts()
        DispatchQueue.main.async {
            self.workouts = workouts.compactMap(WorkoutModel.init)
            print("Number of Workouts: \(self.workouts.count)")
            self.checkForEmptyWorkouts()
            print("Number of Workouts: \(self.workouts.count)")
        }
        
       
    }
    
    var type: String = "TESTING"
    
//    func save() {
//        let manager = CoreDataManager.shared
//        let workout = Workout(context: manager.persistentContainer.viewContext)
//        workout.type = type
//        
//        manager.save()
//        type = ""
//    }
    
    func addNewWorkout(type: String) {
        
        let manager = CoreDataManager.shared
        let workout = Workout(context: manager.persistentContainer.viewContext)
        workout.type = type
        
        manager.save()
        
    }
    
    //func to remove empty workouts after bug was fixed, TODO: Remove eventually
    func checkForEmptyWorkouts() {
        for workout in self.workouts {
            if workout.type == "" {
                self.deleteWorkout(workout: workout)
            } else {
                print("\(workout.type ?? "EMPTY") TYPE")
            }
        }
    }
    
    func addGoal(workout: WorkoutModel, goal: Double) {
        let manager = CoreDataManager.shared
        let _workout = manager.getWorkoutById(id: workout.typeId)
        _workout?.goal = goal
        
        manager.save()
        
        
    }
}

struct WorkoutModel: Hashable {
    
    let workout: Workout
    
    var typeId: NSManagedObjectID {
        return workout.objectID
    }
    
    var type: String? {
        return workout.type
    }
    
    var goal: Double? {
        return workout.goal
    }
}

//
//  WorkoutViewModel.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 9/15/22.
//

import Foundation
import CoreData

@Observable class WorkoutViewModel {
    
    var workouts = [WorkoutModel]()
    
    func deleteWorkout(workout: WorkoutModel) {
        let workout = CoreDataManager.shared.getWorkoutById(id: workout.typeId)
        
        if let workout = workout {
            CoreDataManager.shared.deleteWorkout(workout)
        }
        
        CoreDataManager.shared.save()
    }
    
    func getAllWorkouts() {
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderIndex", ascending: true)]
        
        do {
            let workouts = try CoreDataManager.shared.persistentContainer.viewContext.fetch(fetchRequest)
            self.workouts = workouts.map(WorkoutModel.init)
            print(workouts)
        } catch {
            print("Failed to fetch workouts: \(error)")
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
        workout.orderIndex = Int64(workouts.count) // Place at end of list
        manager.save()
        getAllWorkouts()
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
    
    func updateWorkoutOrder(with models: [WorkoutModel]) {
        for (index, model) in models.enumerated() {
            if let workout = CoreDataManager.shared.getWorkoutById(id: model.typeId) {
                workout.orderIndex = Int64(index)
                print("Set \(workout.type ?? "") to \(index)")
            }
        }
        CoreDataManager.shared.save()
        getAllWorkouts()
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
    
    var orderIndex: Int {
        return Int(workout.orderIndex)
    }
}

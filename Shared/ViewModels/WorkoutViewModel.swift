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
        
        save()
    }
    
    func getAllWorkouts() {
        let workouts = CoreDataManager.shared.getAllWorkouts()
        DispatchQueue.main.async {
            self.workouts = workouts.map(WorkoutModel.init)
        }
    }
    
    var type: String = ""
    
    func save() {
        let manager = CoreDataManager.shared
        let workout = Workout(context: manager.persistentContainer.viewContext)
        workout.type = type
        
        manager.save()
    }
    
    func addNewWorkout(type: String) {
        
        let workout = Workout(context: CoreDataManager.shared.viewContext)
        workout.type = type
        
        save()
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
}

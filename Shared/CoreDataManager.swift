//
//  CoreDataManager.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 9/15/22.
//

import Foundation
import CoreData
import SwiftUI

class CoreDataManager {
    
    let persistentContainer: NSPersistentCloudKitContainer
    
    static let shared = CoreDataManager()
    
    private init() {
        
        persistentContainer = NSPersistentCloudKitContainer(name: "PRTrackerModel")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to initialize Core Data \(error)")
            }
        }
        
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print(directories[0])
    }
    
    var viewContext: NSManagedObjectContext {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    func getWorkoutById(id: NSManagedObjectID) -> Workout? {
        
        do {
            return try persistentContainer.viewContext.existingObject(with: id) as? Workout
        } catch {
            print(error)
            return nil
        }
    }
    
    func getWeightById(id: NSManagedObjectID) -> Weight? {
        do {
            return try persistentContainer.viewContext.existingObject(with: id) as? Weight
        } catch {
            print(error)
            return nil
        }
    }
    
    func deleteWorkout(_ workout: Workout) {
        
        persistentContainer.viewContext.delete(workout)
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            fatalError("Issue deleting workout...\(error)")
        }
    }
    
    func deleteWeight(_ weight: Weight) {
        persistentContainer.viewContext.delete(weight)
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            persistentContainer.viewContext.rollback()
            fatalError("Issue deleting weight...\(error)")
        }
    }
    
    func getAllWorkouts() -> [Workout] {
        
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
        
    }
    
    func save() {
        do {
            try persistentContainer.viewContext.save()
            print("SAVED")
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save a workout \(error)")
        }
    }
}

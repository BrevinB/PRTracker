//
//  CoreDataManager.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 9/15/22.
//

import Foundation
import CoreData
import SwiftUI
import CloudKit

class CoreDataManager {
    
    let persistentContainer: NSPersistentCloudKitContainer
    
    @AppStorage("initialWorkoutSet") private var initialWorkoutSet: Bool = false
    
    static let shared = CoreDataManager()
    
    private init() {
        
        persistentContainer = NSPersistentCloudKitContainer(name: "PRTrackerModel")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Failed to initialize Core Data \(error)")
            }
        }
    }
    
    var viewContext: NSManagedObjectContext {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    func deleteAllWorkouts() {
        let fetchRequest1: NSFetchRequest<NSFetchRequestResult> = Workout.fetchRequest()
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        _ = try? persistentContainer.viewContext.execute(batchDeleteRequest1)
        print("SUCESS")
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
            print("WORKOUT DELETED")
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
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save a workout \(error)")
        }
    }
    
    func checkForExistingData() -> Bool {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        do {
            let data = try persistentContainer.viewContext.fetch(request)
            if !data.isEmpty {
                return true
            } else {
                return false
            }
        } catch {
            
            return false
        }
    }
}

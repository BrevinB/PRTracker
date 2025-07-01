# PR-Tracker
[PR-Tracker](https://apps.apple.com/us/app/pr-tracker/id6443760870) is a workout personal record tracking app. The free version contains sections to track your body weight, bench, squat, deadlift.
Purchasing premium allows you to add additional lifts to track such as overhead press, log press, atlas stones, etc. 

The goal of this app is to allow users to track their personal records with simple charts to see their progress and get motivated to beat previous records! 
With premium you are able to add goals to each lift to help with a visual aid to stay motivated. 

PR-Tracker currently sits at 800+ downloads. 

# Technologies Used
* SwiftUI
* HealthKit
* Swift Charts
* Swift Algorithms
* Git and GitHub
* Core Data
* CloudKit
* RevenueCat

# Promo Video

https://github.com/user-attachments/assets/a3f6bf68-d919-4bad-ab88-96b7c29dcc72


# I'm Most Proud Of....
This project was an idea I've had since 2018 when I first started learning iOS development. After years of having the idea and on and off working on the project I was able to get it deployed on the App Store. 
On top of that, learning Core Data was a big part of this project and it took a while to get through the kinks in the beginning. Here's some of the code for my Core Data model. 

```swift
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
        } catch {
            persistentContainer.viewContext.rollback()
            print("Failed to save a workout \(error)")
        }
    } 
```
# Completeness
Although it is on the App Store I still plan on improving the following
* Error handling & alerts
* Basic unit tests
* Improved Accessibility
* Code documentation (DocC)

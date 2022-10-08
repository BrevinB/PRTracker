//
//  WeightViewModel.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 9/15/22.
//

import Foundation
import CoreData
import SwiftUI

class WeightViewModel: ObservableObject {
    @Published var weights = [WeightModel]()
    @Published var filteredWeights = [WeightModel]()
    
    func getWeightsByType(workoutModel: WorkoutModel) {
        
        let type = CoreDataManager.shared.getWorkoutById(id: workoutModel.typeId)
        if let type = type {
            DispatchQueue.main.async {
                let unsortedWeights = (type.weight?.allObjects as! [Weight]).map(WeightModel.init)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MM, yyyy"
                self.weights = unsortedWeights.sorted(by: { $0.date!.compare($1.date!) == .orderedDescending})
            }
        }
    }
    
    func addOrSubtractMonth(month: Int) -> Date {
        Calendar.current.date(byAdding: .month, value: month, to: Date())!
    }
    
    func filterWeights(month: Int) {
        DispatchQueue.main.async {
            
            //let calendar = Calendar.current
            //let currentDay = Date.now
            if month == 0 {
                self.filteredWeights = self.weights
            } else {
                let now = Date.now
                let previous3Months = self.addOrSubtractMonth(month: month)
                let range = previous3Months...now
                for weight in self.weights {
                    if range.contains(weight.date ?? Date.now) {
                        self.filteredWeights.append(weight)
                    }
                }
                
                self.filteredWeights = self.filteredWeights.sorted(by: { $0.date!.compare($1.date!) == .orderedDescending})
            }
            
//            let filtered = self.weights.filter {
//                return calendar.isDate($0.date ?? Date.now, inSameDayAs: currentDay)
//            }
//
//            DispatchQueue.main.async {
//                withAnimation {
//                    self.filteredWeights = filtered
//                }
//            }
        }
    }
    
    var value: Double = 0.0
    var date: Date = Date()
    var note: String = ""
    
    func addWeightForWorkout(workoutModel: WorkoutModel) {
        let type = CoreDataManager.shared.getWorkoutById(id: workoutModel.typeId)
        
        let weight = Weight(context: CoreDataManager.shared.viewContext)
        weight.value = value
        weight.date = date
        weight.note = note
        weight.type = type
        
        CoreDataManager.shared.save()
    }
    
    func deleteWeight(weight: WeightModel) {
        let value = CoreDataManager.shared.getWeightById(id: weight.weightId)

        if let value = value {
            CoreDataManager.shared.deleteWeight(value)
        }
    }
}

struct WeightModel: Comparable, Identifiable {
    
    var id: ObjectIdentifier {
        return weight.id
    }
    
    static func < (lhs: WeightModel, rhs: WeightModel) -> Bool {
        return lhs.value < rhs.value
    }
    
    let weight: Weight
    
    var weightId: NSManagedObjectID {
        return weight.objectID
    }
    
    var value: Double {
        return weight.value
    }
    
    var date: Date? {
        return weight.date
    }
    
    var note: String? {
        return weight.note
    }
}

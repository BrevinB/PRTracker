//
//  WeightViewModel.swift
//  PRTracker (iOS)
//
//  Created by Brevin Blalock on 9/15/22.
//

import Foundation
import CoreData
import SwiftUI

@Observable class WeightViewModel {
    var weights = [WeightModel]()
    var filteredWeights = [WeightModel]()
    var threeMonthWeights = [WeightModel]()
    var sixMonthWeights = [WeightModel]()
    var oneYearWeights = [WeightModel]()
    var allTimeWeights = [WeightModel]()
    
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
            self.filterAllTime()
            self.filterThreeMonth()
            self.filterSixMonth()
            self.filterOneYear()
            self.filterAllTime()
        }
    }
    
    func filterThreeMonth() {
        DispatchQueue.main.async {
            let previous3Months = self.addOrSubtractMonth(month: -3)
            
            self.threeMonthWeights = self.weights.filter{ $0.date ?? Date.now > previous3Months}.sorted(by: { $0.date!.compare($1.date!) == .orderedDescending})
        }
    }
    
    func filterSixMonth() {
        DispatchQueue.main.async {
            let previous6Months = self.addOrSubtractMonth(month: -6)
            
            self.sixMonthWeights = self.weights.filter{ $0.date ?? Date.now > previous6Months}.sorted(by: { $0.date!.compare($1.date!) == .orderedDescending})
        }
    }
    
    func filterOneYear() {
        DispatchQueue.main.async {
            let previous12Months = self.addOrSubtractMonth(month: -12)
            
            self.oneYearWeights = self.weights.filter{ $0.date ?? Date.now > previous12Months}.sorted(by: { $0.date!.compare($1.date!) == .orderedDescending})
        }
    }
    
    func filterAllTime() {
        DispatchQueue.main.async {
            self.allTimeWeights = self.weights
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
    
    func updateWeight(weightId: NSManagedObjectID, weight: Double, note: String, date: Date) {
        let value = CoreDataManager.shared.getWeightById(id: weightId)
        
        if let value = value {
            value.value = weight
            value.note = note
            value.date = date
            CoreDataManager.shared.save()
        }
    }
}

struct WeightModel: Comparable, Identifiable {

    var id: NSManagedObjectID {
        return weight.objectID
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

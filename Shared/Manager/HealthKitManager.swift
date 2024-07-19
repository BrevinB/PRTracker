//
//  HealthKitViewModel.swift
//  PRTracker
//
//  Created by Brevin Blalock on 3/24/23.
//

import Foundation
import HealthKit

@Observable class HealthKitManager {
    private var healthStore = HKHealthStore()
    private var healthKitManager = HealthKitStore()
    let WorkoutVM = WorkoutViewModel()
    let WeightVM = WeightViewModel()
    var userBodyMass = "Empty"
    var isAuthorized = false
    var isHealthDataDone = false
    struct healthKitWeight: Identifiable, Equatable {
        var id = UUID()
        var weight: Double
        var date: Date
    }
    var testingWeightModel: [WeightModel] = []
    var testingData: [healthKitWeight] = []
    
    func healthRequest() {
        healthKitManager.setUpHealthRequest(healthStore: healthStore) {
            self.changeAuthorizationStatus()
        }
    }
    
    
    func changeAuthorizationStatus() {
        guard let weightQtyType = HKObjectType.quantityType(forIdentifier: .bodyMass) else { return }
        let status = self.healthStore.authorizationStatus(for: weightQtyType)
        
        switch status {
        case .notDetermined:
            isAuthorized = false
        case .sharingDenied:
            isAuthorized = false
        case .sharingAuthorized:
            isAuthorized = true
        @unknown default:
            isAuthorized = false
        }
    }
    
    func importData() {
        healthKitManager.importOldData(healthStore: healthStore)
    }
    
    func importIntoHealthKit(date: String, bodyMass: Double) {
        healthKitManager.importBodyMassData(date: date, bodyMass: bodyMass)
    }
    
    func deleteData(date: Date, bodyMass: Double) {
        healthKitManager.deleteBodyMassData(dateDelete: date, bodyMassDelete: bodyMass)
    }
    
    func getHealthKitData() async -> [healthKitWeight] {
        
        await healthKitManager.getWeightData(forDay: 10, healthStore: healthStore) { weight, date in
                let newVal = healthKitWeight(weight: weight!, date: date!)
                self.testingData.append(newVal)
                //self.isHealthDataDone = true
                
            }
        
        return testingData
    }
    
    func checkData(workoutVM: WorkoutViewModel, weightVM: WeightViewModel) async {
        var CDWeights: [WeightModel] = []
        workoutVM.getAllWorkouts()
        if let bodyWeight = workoutVM.workouts.first(where: {$0.type == "Body Weight"}) {
           // do something with foo
            Task {
                await weightVM.getWeightsByType(workoutModel: bodyWeight)
            }
            CDWeights = weightVM.weights
            //let testDifferences = testingData.difference(from: CDWeights)
            
            var testingArrayData: [healthKitWeight] = []
            for HKweight in testingData {
                let newVal = healthKitWeight(weight: HKweight.weight, date: HKweight.date)
                testingArrayData.append(newVal)
            }
            if CDWeights.count >= testingData.count {
                //delete from healthkit?
                CDWeights.removeAll()
                testingData.removeAll()
            } else {
                //import old data
                let differences = testingArrayData.difference(from: testingData)
                _ = differences.insertions.compactMap { change -> IndexPath? in
                  guard case let .insert(offset, _, _) = change
                    else { return nil }

                  return IndexPath(row: offset, section: 0)
                }
                
                print(differences.removals)
                
                _ = differences.removals.compactMap { change -> IndexPath? in
                  guard case let .remove(offset, _, _) = change
                    else { return nil }

                  return IndexPath(row: offset, section: 0)
                }
                
                
                CDWeights.removeAll()
                testingData.removeAll()
            }
        } else {
           // item could not be found
            print("Item not found")
        }
    }
    
    func testingFetchData() async throws -> String {
        await healthKitManager.getWeightData(forDay: 10, healthStore: healthStore) { weight, date in
                let newVal = healthKitWeight(weight: weight!, date: date!)
                self.testingData.append(newVal)
                self.isHealthDataDone = true
                
            }
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Simulating a 2-second delay
        return "Fetching is done"
    }
    
    func fetchDataAndReport(workoutVM: WorkoutViewModel, weightVM: WeightViewModel) async -> Bool {
        do {
            let data = try await testingFetchData()
            await checkData(workoutVM: workoutVM, weightVM: weightVM)
            DispatchQueue.main.async {
                // Update the UI once the health data is available
                //self.healthData = data
                print(data.count)
            }
            return true
        } catch {
            print("Error fetching health data: \(error)")
            return false
        }
    }
}

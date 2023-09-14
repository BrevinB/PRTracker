//
//  HealthKitStore.swift
//  PRTracker
//
//  Created by Brevin Blalock on 3/23/23.
//

import Foundation
import HealthKit

class HealthKitStore {
    
    enum HealthKitError: Error {
        case cantFindData
        case insufficientFunds(coinsNeeded: Int)
        case outOfStock
    }
    
    func setUpHealthRequest(healthStore: HKHealthStore, readSteps: @escaping () -> Void) {
        if HKHealthStore.isHealthDataAvailable(), let bodyWeight = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass) {
            healthStore.requestAuthorization(toShare: [bodyWeight], read: [bodyWeight]) { success, error in
                if success {
                    //Authorization granted, start syncing data
                    //self.startHealthKitObservation(healthStore: healthStore)
                } else if error != nil {
                    //handle error
                    print(error ?? "Error")
                }
            }
        }
    }
    
    func startHealthKitObservation(healthStore: HKHealthStore) {
        let query = HKObserverQuery(sampleType: HKObjectType.quantityType(forIdentifier: .bodyMass)!, predicate: nil) { (query, completionHandler, error) in
               if error == nil {
                   // HealthKit data changed, import into app
                   self.importHealthKitData()
               }
           }
           
           healthStore.execute(query)
    }
    
    func importHealthKitData() {
        
    }
    
    
    func getWeightData(forDay days: Int, healthStore: HKHealthStore, completion: @escaping ((_ weight: Double?, _ date: Date?) -> Void)) async {
        guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
            print("Unable to create a bodyMass type")
            return
        }
        
        let now = Date()
        let startDate = Calendar.current.date(byAdding: DateComponents(day: -days), to: now)!
        
        var interval = DateComponents()
        interval.day = 1
        
        var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: now)
        anchorComponents.hour = 0
        let anchorDate = Calendar.current.date(from: anchorComponents)!
        
        let query = HKStatisticsCollectionQuery(quantityType: bodyMassType,
                                                quantitySamplePredicate: nil,
                                                options: [.mostRecent],
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        query.initialResultsHandler = { _, results, error in
            guard let results = results else {
                print("ERROR")
                return
            }
            
            results.enumerateStatistics(from: startDate, to: now) { statistics, _  in
                if let sum = statistics.mostRecentQuantity() {
                    let bodyMassValue = sum.doubleValue(for: .pound()).rounded()
                    completion(bodyMassValue, statistics.startDate)
                    return
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    func importOldData(healthStore: HKHealthStore) {
        // Check if body mass data is available
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit data is not available")
            return
        }
        
        // Request authorization to read body mass data
        let typesToRead: Set<HKQuantityType> = [HKQuantityType.quantityType(forIdentifier: .bodyMass)!]
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            if let error = error {
                print("Error requesting HealthKit authorization: \(error.localizedDescription)")
                return
            }
            
            if success {
                // Set the date range for the past three months
                let endDate = Date()
                let calendar = Calendar.current
                let startDate = calendar.date(byAdding: .month, value: -3, to: endDate)
                // Create the predicate for the query
                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
                
                // Create the query for body mass data
                let query = HKSampleQuery(
                    sampleType: HKQuantityType.quantityType(forIdentifier: .bodyMass)!,
                    predicate: predicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: nil
                ) { query, results, error in
                    if let error = error {
                        print("Error fetching body mass data: \(error.localizedDescription)")
                        return
                    }
                    
                    if let bodyMassSamples = results as? [HKQuantitySample] {
                        let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                        
                        for sample in bodyMassSamples {
                            let bodyMass = sample.quantity.doubleValue(for: .pound())
                            let date = sample.endDate
                            let startDate = sample.startDate
                            let formattedDate = dateFormatter.string(from: date)
                            let formattedStartDate = dateFormatter.string(from: startDate)
                            print(bodyMass.description)
                            print(formattedDate)
                            print(formattedStartDate)
                        }
                    }
                }
                
                healthStore.execute(query)
            }
        }
    }
    
    func importBodyMassData(date: String, bodyMass: Double) {
        let healthStore = HKHealthStore()

        // Check if body mass data is available
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit data is not available")
            return
        }

        // Request authorization to write body mass data
        let typesToWrite: Set<HKSampleType> = [HKQuantityType.quantityType(forIdentifier: .bodyMass)!]
        healthStore.requestAuthorization(toShare: typesToWrite, read: nil) { success, error in
            if let error = error {
                print("Error requesting HealthKit authorization: \(error.localizedDescription)")
                return
            }

            if success {
                // Create body mass data samples
                let bodyMassType = HKQuantityType.quantityType(forIdentifier: .bodyMass)!
                let bodyMassUnit = HKUnit.pound()

                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
                
                // Example data: array of tuples with date string and body mass in kilograms
                let bodyMassData: [(String, Double)] = [
                    (date, bodyMass)
                ]
                
                for data in bodyMassData {
                    if let date = dateFormatter.date(from: data.0) {
                        let quantity = HKQuantity(unit: bodyMassUnit, doubleValue: data.1)
                        let bodyMassSample = HKQuantitySample(
                            type: bodyMassType,
                            quantity: quantity,
                            start: date,
                            end: date
                        )
                        // Save the body mass sample to HealthKit
                        healthStore.save(bodyMassSample) { success, error in
                            if let error = error {
                                print("Error saving body mass sample: \(error.localizedDescription)")
                            } else {
                                print("Body mass sample saved successfully")
                            }
                        }
                    } else {
                        print("Invalid date format: \(data.0)")
                    }
                }
            }
        }
    }

    func deleteBodyMassData(dateDelete: Date, bodyMassDelete: Double) {
        let healthStore = HKHealthStore()

        // Check if body mass data is available
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit data is not available")
            return
        }

        // Request authorization to write body mass data
        let typesToWrite: Set<HKSampleType> = [HKQuantityType.quantityType(forIdentifier: .bodyMass)!]
        healthStore.requestAuthorization(toShare: typesToWrite, read: nil) { success, error in
            if let error = error {
                print("Error requesting HealthKit authorization: \(error.localizedDescription)")
                return
            }

            if success {
                
                // Create the body mass type
                  guard let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass) else {
                      // Handle error - Body mass type not available
                      print("Body Mass type not available")
                      return
                  }
                  
                  // Create a predicate to identify the specific body mass value you want to delete
                  let predicate = NSPredicate(format: "startDate >= %@ AND endDate <= %@", dateDelete as NSDate, dateDelete as NSDate)
                  
                  // Create a query to retrieve the body mass samples
                  let query = HKSampleQuery(sampleType: bodyMassType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                      guard let results = results else {
                          // Handle error
                          print("query error")
                          return
                      }
                      
                      // Delete the specific body mass samples
                      let samplesToDelete = results as! [HKQuantitySample]
                      healthStore.delete(samplesToDelete, withCompletion: { (success, error) in
                          if success {
                              // Body mass samples deleted successfully
                            
                          } else {
                              // Handle error
                              print(error!)
                              print(samplesToDelete.count)
                          }
                      })
                  }

                healthStore.execute(query)
            }
        }
    }

}
